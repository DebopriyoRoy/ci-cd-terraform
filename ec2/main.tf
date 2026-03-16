# ==============================================================================
# EC2 INSTANCE — crtd-from-jenkins
# Placed inside the crt-from-jenkins VPC (public subnet), attached to the
# ec2-from-jenkins IAM instance profile and the VPC security group.
# ==============================================================================
resource "aws_instance" "ec2_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  # Subnet from the vpc module (public subnet in us-east-1a)
  subnet_id = var.subnet_id

  # Security group from the vpc module
  vpc_security_group_ids = var.vpc_security_group_ids

  # IAM instance profile from the iam module (ec2-from-jenkins)
  iam_instance_profile = var.iam_instance_profile

  # Assign a public IP explicitly
  associate_public_ip_address = true

  tags = {
    Name      = "crtd-from-jenkins"
    Project   = "ci-cd"
    ManagedBy = "terraform"
  }
}
