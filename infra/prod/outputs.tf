# ===== PRODUCTION OUTPUTS =====

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.ecs_app.alb_dns_name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_app.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs_app.service_name
}

output "cloudwatch_dashboard_url" {
  description = "URL to the CloudWatch monitoring dashboard"
  value       = module.ecs_app.cloudwatch_dashboard_url
}