# ==============================================================================
# VPC
# ==============================================================================
resource "aws_vpc" "vpc_inst" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = var.vpc_name
  })
}

# ==============================================================================
# INTERNET GATEWA
# ci-cd-igw — shown under Network Connections in the console
# ==============================================================================
resource "aws_internet_gateway" "vpc_inst" {
  vpc_id = aws_vpc.vpc_inst.id

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-igw"
  })
}

# ==============================================================================
# PUBLIC SUBNETS
# ci-cd-subnet-public1-us-east-1a  (us-east-1a)
# ci-cd-subnet-public2-us-east-1b  (us-east-1b)
# ==============================================================================
resource "aws_subnet" "public" {
  for_each = { for s in var.public_subnets : s.name => s }

  vpc_id                  = aws_vpc.vpc_inst.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = each.value.name
    Tier = "public"
  })
}

# ==============================================================================
# PRIVATE SUBNETS
# ci-cd-subnet-private1-us-east-1a  (us-east-1a)
# ci-cd-subnet-private2-us-east-1b  (us-east-1b)
# ==============================================================================
resource "aws_subnet" "private" {
  for_each = { for s in var.private_subnets : s.name => s }

  vpc_id            = aws_vpc.vpc_inst.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, {
    Name = each.value.name
    Tier = "private"
  })
}

# ==============================================================================
# PUBLIC ROUTE TABLE  →  ci-cd-rtb-public
# Single table shared by both public subnets; routes egress via the IGW
# ==============================================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc_inst.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_inst.id
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-rtb-public"
  })
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# ==============================================================================
# PRIVATE ROUTE TABLES  (one per AZ — isolated, local traffic only)
# ci-cd-rtb-private1-us-east-1a
# ci-cd-rtb-private2-us-east-1b
# ==============================================================================
resource "aws_route_table" "private" {
  for_each = { for s in var.private_subnets : s.name => s }

  vpc_id = aws_vpc.vpc_inst.id

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-rtb-${each.key}"
  })
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

# ==============================================================================
# S3 VPC ENDPOINT  →  ci-cd-vpce-s3
# Gateway type (free). Attached to every route table so all subnets reach
# S3 over the AWS backbone without touching the public internet.
# Shown under Network Connections in the console alongside the IGW.
# ==============================================================================
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc_inst.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    [aws_route_table.public.id],
    [for rt in aws_route_table.private : rt.id]
  )

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-vpce-s3"
  })
}
