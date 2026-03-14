# ==============================================================================
# VPC
# ==============================================================================
output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "Primary IPv4 CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

# ==============================================================================
# INTERNET GATEWAY
# ==============================================================================
output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}

# ==============================================================================
# SUBNETS
# ==============================================================================
output "public_subnet_ids" {
  description = "Map of public subnet name → subnet ID."
  value       = { for k, s in aws_subnet.public : k => s.id }
}

output "private_subnet_ids" {
  description = "Map of private subnet name → subnet ID."
  value       = { for k, s in aws_subnet.private : k => s.id }
}

output "public_subnet_ids_list" {
  description = "Ordered list of public subnet IDs (convenient for ALB, ASG, EKS, etc.)."
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids_list" {
  description = "Ordered list of private subnet IDs."
  value       = [for s in aws_subnet.private : s.id]
}

# ==============================================================================
# ROUTE TABLES
# ==============================================================================
output "public_route_table_id" {
  description = "ID of the shared public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Map of private subnet name → private route table ID."
  value       = { for k, rt in aws_route_table.private : k => rt.id }
}

# ==============================================================================
# VPC ENDPOINT
# ==============================================================================
output "s3_vpc_endpoint_id" {
  description = "ID of the S3 Gateway VPC endpoint."
  value       = aws_vpc_endpoint.s3.id
}
