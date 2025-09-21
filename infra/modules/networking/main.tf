# ===== NETWORKING MODULE =====
# Production-ready VPC with VPC Endpoints for ECR (no NAT Gateway needed)
# This module creates a complete networking setup for production workloads

# Creates the main VPC with a custom CIDR block
# Enables DNS hostnames and support for proper service discovery
# This is the foundation network where all resources will be deployed
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.tags
}

# Creates an Internet Gateway for public internet access
# Allows resources in public subnets to reach the internet
# Required for the Application Load Balancer to receive external traffic
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = var.tags
}

# Creates public subnets across multiple availability zones
# These subnets host the Application Load Balancer
# Resources here get public IP addresses and internet access
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = var.tags
}

# Creates private subnets across multiple availability zones
# These subnets host the ECS containers (no direct internet access)
# Traffic flows through VPC endpoints for AWS services like ECR
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = var.tags
}

# Route table for public subnets with internet gateway route
# Directs all internet traffic (0.0.0.0/0) through the Internet Gateway
# This enables public subnets to communicate with the internet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = var.tags
}

# Route table for private subnets (no NAT Gateway to save costs)
# Uses VPC endpoints instead of NAT Gateway for AWS service access
# Private subnets cannot reach the internet directly
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = var.tags
}

# Associates each public subnet with the public route table
# This connects public subnets to internet gateway routing
# Required for ALB to receive traffic from the internet
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associates each private subnet with the private route table
# This isolates private subnets from direct internet access
# ECS tasks use VPC endpoints to access AWS services
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Security group that controls access to VPC endpoints
# Allows HTTPS traffic from within the VPC only
# Enables secure communication between ECS tasks and AWS services
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.environment}-vpc-endpoints-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for VPC endpoints"

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# VPC endpoint for ECR API access from private subnets
# Allows ECS tasks to authenticate and pull container images from ECR
# Eliminates need for NAT Gateway to reach ECR service
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = var.tags
}

# VPC endpoint for ECR Docker registry access from private subnets  
# Required for ECS Fargate to pull container image layers from ECR
# Works together with ECR API endpoint for complete ECR access
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = var.tags
}

# VPC endpoint for S3 access (gateway type for cost efficiency)
# ECR stores Docker image layers in S3, so this enables image pulls
# Gateway endpoint is free vs Interface endpoint which has hourly charges
# Gateway endpoint only works if we add routes to the private route table
# Gateway endpoint only works with s3 and dynamodb.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = var.tags
}

# VPC endpoint for CloudWatch Logs from private subnets
# Allows ECS tasks to send logs to CloudWatch without internet access
# Essential for monitoring and debugging containerized applications
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = var.tags
}