# ===== EC2 MODULE =====
# Reusable module for deploying EC2 instances with Docker
# Used by both dev and prod environments

# Data source to reference existing ECR repository
data "aws_ecr_repository" "node_hello" {
  name = "node-hello"
}

# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for EC2 instance
resource "aws_security_group" "ec2_sg" {
  name_prefix = "${var.environment}-ec2-sg"
  vpc_id      = var.vpc_id
  description = "Security group for ${var.environment} EC2 instance"

  # HTTP access for Node.js app
  ingress {
    description = "HTTP for Node.js app"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # SSH access (optional, for debugging)
  dynamic "ingress" {
    for_each = var.enable_ssh ? [1] : []
    content {
      description = "SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_cidr_blocks
    }
  }

  # Outbound internet access (for Docker pulls from ECR)
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-ec2-security-group"
  })
}

# IAM role for EC2 to access ECR
resource "aws_iam_role" "ec2_role" {
  name = "${var.environment}-ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM policy for ECR access
resource "aws_iam_role_policy" "ecr_policy" {
  name = "${var.environment}-ecr-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = var.tags
}

# User data script to install Docker and run the container
locals {
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    ecr_repository_url = data.aws_ecr_repository.node_hello.repository_url
    aws_region        = var.aws_region
    container_name    = var.container_name
  }))
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name              = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id             = var.subnet_id
  iam_instance_profile  = aws_iam_instance_profile.ec2_profile.name

  user_data = local.user_data

  # Enable detailed monitoring if specified
  monitoring = var.enable_detailed_monitoring

  tags = merge(var.tags, {
    Name = "${var.environment}-app-server"
  })

  # Ensure the instance is replaced if user data changes
  user_data_replace_on_change = true
}