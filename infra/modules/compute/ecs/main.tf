# ===== ECS MODULE =====
# Production-ready ECS Fargate setup with ALB integration
# This module creates ECS cluster, service, task definition, and Application Load Balancer

# References the existing ECR repository created earlier
# This data source allows us to get the repository URL for container images
# No need to create a new ECR repo since we're reusing the one from dev
data "aws_ecr_repository" "node_hello" {
  name = "node-hello"
}

# Creates an ECS cluster to host our containerized application
# Container Insights disabled to avoid extra charges ($0.50/container/month)
# Basic metrics like CPU and memory are still free at 1-minute intervals
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-cluster"
  
  setting {
    name  = "containerInsights"
    value = "disabled"  # Keep disabled to avoid charges, basic metrics are free anyway
  }
  
  tags = var.tags
}

# CloudWatch Log Group for ECS
# ECS tasks will log container stdout/stderr here via the awslogs driver.
# Retention of 7 days avoids unnecessary log storage cost.
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.environment}-app"
  retention_in_days = 7
  tags = var.tags
}

# Creates a CloudWatch dashboard for monitoring our application
# Displays free basic metrics: CPU, memory, response time, and request count
# Provides visual monitoring without additional CloudWatch charges
resource "aws_cloudwatch_dashboard" "ecs_monitoring" {
  dashboard_name = "${var.environment}-ecs-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", aws_ecs_service.main.name, "ClusterName", aws_ecs_cluster.main.name],
            [".", "MemoryUtilization", ".", ".", ".", "."],
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ECS Service - CPU and Memory"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.main.arn_suffix],
            [".", "RequestCount", ".", "."],
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Load Balancer - Response Time and Requests"
          period  = 300
        }
      }
    ]
  })
}

# Defines the ECS task specification (blueprint for containers)
# Specifies CPU, memory, IAM roles, networking, and container configuration
# Uses Fargate launch type for serverless container execution
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.environment}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name  = "${var.environment}-app"
    image = "${data.aws_ecr_repository.node_hello.repository_url}:${var.image_tag}"

    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])

  tags = var.tags
}

# Security group controlling traffic to ECS tasks in private subnets
# Only allows inbound traffic from the Application Load Balancer
# Enables secure communication while preventing direct external access
resource "aws_security_group" "ecs_tasks" {
  name_prefix = "${var.environment}-ecs-tasks-"
  vpc_id      = var.vpc_id
  description = "Security group for ECS tasks"

  ingress {
    description     = "HTTP from ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# Security group for the Application Load Balancer
# Allows HTTP traffic from the internet (port 80)
# Acts as the entry point for external users to access the application
resource "aws_security_group" "alb" {
  name_prefix = "${var.environment}-alb-"
  vpc_id      = var.vpc_id
  description = "Security group for Application Load Balancer"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# Application Load Balancer deployed in public subnets
# Receives traffic from the internet and distributes it to ECS tasks
# Provides high availability across multiple availability zones
resource "aws_lb" "main" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets           = var.public_subnet_ids

  enable_deletion_protection = false

  tags = var.tags
}

# Target group that defines how the ALB routes traffic to ECS tasks
# Performs health checks to ensure traffic only goes to healthy containers
# Uses IP targeting since Fargate tasks get dynamic IP addresses
resource "aws_lb_target_group" "app" {
  name        = "${var.environment}-app-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = "3"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
    unhealthy_threshold = "2"
  }

  tags = var.tags
}

# ALB listener that defines how the load balancer handles incoming requests
# Listens on port 80 for HTTP traffic from the internet
# Forwards all requests to the target group containing our ECS tasks
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  tags = var.tags
}

# ECS service that maintains the desired number of running tasks
# Automatically replaces unhealthy tasks and integrates with the load balancer
# Deploys tasks in private subnets for security while allowing ALB access
resource "aws_ecs_service" "main" {
  name            = "${var.environment}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets         = var.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "${var.environment}-app"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.web]

  tags = var.tags
}

# IAM role that ECS uses to pull images and write logs during task startup
# This is the "execution role" that handles container lifecycle operations
# Required for Fargate tasks to access ECR and CloudWatch Logs
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.environment}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM role that the running container itself assumes (task role)
# Used for any AWS API calls made by your application code
# Currently minimal since our Node.js app doesn't call AWS services
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attaches AWS managed policy for basic ECS execution capabilities
# Provides permissions for CloudWatch Logs and basic ECS operations
# This is a standard AWS-managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional custom policy for ECR access from private subnets
# Allows the execution role to authenticate and pull images from ECR
# Required when using VPC endpoints instead of NAT Gateway
resource "aws_iam_role_policy" "ecs_execution_role_ecr_policy" {
  name = "${var.environment}-ecs-execution-ecr-policy"
  role = aws_iam_role.ecs_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}