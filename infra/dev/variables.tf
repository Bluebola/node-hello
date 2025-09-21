# ===== DEV ENVIRONMENT VARIABLES =====
# Input variables for the dev environment

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "govtechthadev"
}

variable "instance_type" {
  description = "EC2 instance type for dev environment"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access (optional)"
  type        = string
  default     = null
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the application"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Allow from anywhere for dev
}

variable "enable_ssh" {
  description = "Enable SSH access for development"
  type        = bool
  default     = false  # Disabled by default for security
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # If SSH enabled, allow from anywhere in dev
}

variable "container_name" {
  description = "Name for the Docker container"
  type        = string
  default     = "node-hello-dev"
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false  # Keep costs low in dev
}