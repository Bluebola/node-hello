#!/bin/bash
# Simple EC2 startup script - install Docker and run container

# Install Docker
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker

# Authenticate with ECR (AWS CLI is pre-installed on Amazon Linux 2)
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${ecr_repository_url}

# Pull and run the container
docker run -d \
  --name ${container_name} \
  --restart unless-stopped \
  -p 3000:3000 \
  ${ecr_repository_url}:latest