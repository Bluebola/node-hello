# ===== DEV ENVIRONMENT CONFIGURATION =====
# Variable values specific to the dev environment

# Basic configuration
aws_region   = "ap-southeast-1"
environment  = "dev"
project_name = "govtechthadev"

# Instance configuration (keep it small and cheap for dev)
instance_type = "t2.micro"

# Security configuration
allowed_cidr_blocks = ["0.0.0.0/0"]  # Allow access from anywhere for testing
enable_ssh         = false           # Disable SSH for security (can enable if needed)

# Application configuration
container_name = "node-hello-dev"

# Monitoring (keep minimal for cost savings)
enable_detailed_monitoring = false

# Optional: Uncomment and set if you want SSH access
# key_name = "your-ec2-keypair-name"
# enable_ssh = true
# ssh_cidr_blocks = ["YOUR_IP/32"]  # Replace with your IP for security