# ===== PRODUCTION ENVIRONMENT =====
# Production environment using custom VPC with ECS Fargate and ALB

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state backend configuration - update with your S3 bucket name
  backend "s3" {
    bucket         = "terraform-state-govtech-nodeapp-prod-tl"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-state-locks-prod"
    encrypt        = true
  }
}

# Configure AWS Provider with default tags for all resources
# Applies consistent tagging across the entire production environment
# Default tags help with cost tracking and resource management
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project = "govtechTHAprod"
    }
  }
}

# Deploy custom VPC with private/public subnets and VPC endpoints
# Creates production-grade networking without NAT Gateway costs
# VPC endpoints enable secure access to AWS services from private subnets
module "networking" {
  source = "../modules/networking"
  
  environment        = var.environment
  aws_region        = var.aws_region
  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones
  
  tags = {
    Project = "govtechTHAprod"
  }
}

# Deploy ECS Fargate cluster with Application Load Balancer
# Provides serverless container hosting with automatic scaling
# Integrates with ALB for high availability and health checking
module "ecs_app" {
  source = "../modules/compute/ecs"
  
  environment = var.environment
  aws_region  = var.aws_region
  
  # Networking configuration
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  
  # Application configuration
  container_port = var.container_port
  task_cpu      = var.task_cpu
  task_memory   = var.task_memory
  desired_count = var.desired_count
  image_tag     = var.image_tag
  
  tags = {
    Project = "govtechTHAprod"
  }
}