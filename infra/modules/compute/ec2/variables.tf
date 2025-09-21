# ===== EC2 MODULE VARIABLES =====
# Input variables for the reusable EC2 module

variable "environment" {
  description = "Environment name (dev, prod, staging, etc.)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Environment must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vpc_id" {
  description = "VPC ID where the EC2 instance will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be deployed"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
  
  validation {
    condition = contains([
      "t2.nano", "t2.micro", "t2.small", "t2.medium",
      "t3.nano", "t3.micro", "t3.small", "t3.medium"
    ], var.instance_type)
    error_message = "Instance type must be a valid t2/t3 instance type."
  }
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access (optional)"
  type        = string
  default     = null
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the application (port 3000)"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Allow from anywhere by default
}

variable "enable_ssh" {
  description = "Enable SSH access to the EC2 instance"
  type        = bool
  default     = false
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access (only used if enable_ssh is true)"
  type        = list(string)
  default     = []
}

variable "aws_region" {
  description = "AWS region for ECR authentication"
  type        = string
  default     = "ap-southeast-1"
}

variable "container_name" {
  description = "Name for the Docker container"
  type        = string
  default     = "node-hello-app"
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring for the EC2 instance"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}