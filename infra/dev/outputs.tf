# ===== DEV ENVIRONMENT OUTPUTS =====
# Output values from the dev environment

output "application_url" {
  description = "URL to access the Node.js application"
  value       = module.ec2_app.application_url
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2_app.instance_public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2_app.instance_id
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.ec2_app.security_group_id
}

output "vpc_id" {
  description = "VPC ID being used (default VPC)"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Subnet ID being used"
  value       = data.aws_subnet.default.id
}

output "ecr_repository_url" {
  description = "ECR repository URL being used"
  value       = module.ec2_app.ecr_repository_url
}