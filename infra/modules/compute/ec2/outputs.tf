# ===== EC2 MODULE OUTPUTS =====
# Output values from the EC2 module

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.app_server.public_dns
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.ec2_sg.id
}

output "application_url" {
  description = "URL to access the Node.js application"
  value       = "http://${aws_instance.app_server.public_ip}:3000"
}

output "ecr_repository_url" {
  description = "ECR repository URL being used"
  value       = data.aws_ecr_repository.node_hello.repository_url
}

output "iam_role_arn" {
  description = "ARN of the IAM role attached to the EC2 instance"
  value       = aws_iam_role.ec2_role.arn
}