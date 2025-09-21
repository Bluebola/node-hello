# ===== DEV ENVIRONMENT =====
# Development environment using default VPC and our EC2 module

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state backend configuration
  backend "s3" {
    bucket         = "terraform-state-govtech-nodeapp-dev-tl"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-state-locks-dev"
    encrypt        = true
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment   = var.environment
      Project      = var.project_name
      ManagedBy    = "Terraform"
      Owner        = "DevOps"
    }
  }
}

# Data source to find the default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source to find a public subnet in the default VPC
data "aws_subnet" "default" {
  vpc_id               = data.aws_vpc.default.id
  availability_zone    = "${var.aws_region}a"
  default_for_az       = true
}

# Use our EC2 module to deploy the application
module "ec2_app" {
  source = "../modules/compute/ec2"
  
  # Environment configuration
  environment = var.environment
  
  # Networking (using default VPC)
  vpc_id    = data.aws_vpc.default.id
  subnet_id = data.aws_subnet.default.id
  
  # Instance configuration
  instance_type = var.instance_type
  key_name     = var.key_name
  
  # Security configuration
  allowed_cidr_blocks = var.allowed_cidr_blocks
  enable_ssh         = var.enable_ssh
  ssh_cidr_blocks    = var.ssh_cidr_blocks
  
  # Application configuration
  aws_region     = var.aws_region
  container_name = var.container_name
  
  # Monitoring
  enable_detailed_monitoring = var.enable_detailed_monitoring
  
  # Tags
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}