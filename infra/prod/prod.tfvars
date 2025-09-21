# ===== PRODUCTION ENVIRONMENT CONFIGURATION =====
# Simple, focused configuration for production

# Basic configuration
aws_region   = "ap-southeast-1"
environment  = "prod"

# VPC configuration
vpc_cidr = "10.0.0.0/16"
availability_zones = ["ap-southeast-1a", "ap-southeast-1b"]

# Application configuration
container_port = 3000
task_cpu      = "256"
task_memory   = "512"
desired_count = 1
image_tag     = "latest"