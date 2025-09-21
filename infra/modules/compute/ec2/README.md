# EC2 Module

This module creates an EC2 instance configured to run a Docker container from ECR.

## Features

- **Docker-ready EC2 instance** with Amazon Linux 2
- **ECR integration** with automatic authentication
- **Configurable security groups** with HTTP and optional SSH access
- **IAM roles** for secure ECR access
- **Health monitoring** with automatic container restart
- **Flexible networking** (works with default VPC or custom VPC)

## Usage

```hcl
module "ec2_app" {
  source = "../modules/compute/ec2"
  
  environment    = "dev"
  vpc_id        = "vpc-12345678"
  subnet_id     = "subnet-12345678"
  instance_type = "t2.micro"
  
  # Optional: Enable SSH access
  enable_ssh      = true
  key_name       = "my-ec2-keypair"
  ssh_cidr_blocks = ["10.0.0.0/8"]
  
  # Tagging
  tags = {
    Environment = "dev"
    Project     = "govtechthadev"
  }
}
```

## Requirements

- **ECR Repository**: Must exist with name "node-hello"
- **VPC & Subnet**: Must be provided (can be default VPC)
- **EC2 Key Pair**: Optional, only needed for SSH access

## Outputs

- `application_url`: Direct URL to access the Node.js app
- `instance_public_ip`: Public IP of the EC2 instance
- `instance_id`: EC2 instance identifier
- `security_group_id`: Security group for additional configuration

## What it deploys

1. **EC2 Instance** (t2.micro by default)
2. **Security Group** (allows port 3000, optional SSH)
3. **IAM Role** with ECR read permissions
4. **Docker Container** running your Node.js app
5. **Health Monitoring** with auto-restart capability

## Cost Estimate (Dev Environment)

- t2.micro EC2: ~$8.50/month (free tier eligible)
- EBS Storage: ~$1/month for 8GB
- **Total**: ~$9.50/month

## Reusability

This module is designed to be reused across environments:
- **Dev**: Single t2.micro in default VPC
- **Prod**: Larger instances in custom VPC with load balancing