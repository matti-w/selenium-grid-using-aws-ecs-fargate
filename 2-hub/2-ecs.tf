# Terraform Block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}

# Provider Block
provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {}
}


data "terraform_remote_state" "infrastructure" {
  backend = "s3"

  config = {
    key    = var.remote_state_key
    bucket = var.remote_state_bucket
    region = var.region
  }
}

data "template_file" "ecs_task_definition_template" {
  template = file("task_definition.json")

  vars = {
    task_definition_name  = var.ecs_service_name
    ecs_service_name      = var.ecs_service_name
    docker_image_url      = var.docker_image_url
    memory                = var.memory
    docker_container_port = var.docker_container_port
    region                = var.region
  }
}

resource "aws_ecs_task_definition" "hub-task-definition" {
  container_definitions    = data.template_file.ecs_task_definition_template.rendered
  family                   = var.ecs_service_name
  cpu                      = 512
  memory                   = var.memory
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.fargate_iam_role.arn
  task_role_arn            = aws_iam_role.fargate_iam_role.arn
}

resource "aws_iam_role" "fargate_iam_role" {
  name = "${var.ecs_service_name}-IAM-Role"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
 {
   "Effect": "Allow",
   "Principal": {
     "Service": ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
   },
   "Action": "sts:AssumeRole"
  }
  ]
 }
EOF
}

resource "aws_iam_role_policy" "fargate_iam_policy" {
  name = "${var.ecs_service_name}-IAM-Role"
  role = aws_iam_role.fargate_iam_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*",
        "ecr:*",
        "logs:*",
        "cloudwatch:*",
        "elasticloadbalancing:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_ecs_service" "ecs_service" {
  name            = var.ecs_service_name
  task_definition = var.ecs_service_name
  desired_count   = var.desired_task_number
  cluster         = data.terraform_remote_state.infrastructure.outputs.ecs_cluster_name
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.terraform_remote_state.infrastructure.outputs.public_subnets
    security_groups  = [aws_security_group.hub_security_group.id]
    assign_public_ip = true
  }

  load_balancer {
    container_name   = var.ecs_service_name
    container_port   = var.docker_container_port
    target_group_arn = aws_alb_target_group.ecs_app_target_group.arn
  }

  service_registries {
    registry_arn = aws_service_discovery_service.selenium_hub.arn
  }
}

resource "aws_security_group" "hub_security_group" {
  name        = "${var.ecs_service_name}-SG"
  description = "Security group for hub to communicate in and out"
  vpc_id      = data.terraform_remote_state.infrastructure.outputs.vpc_id

  ingress {
    from_port   = 4442
    protocol    = "TCP"
    to_port     = 4442
    cidr_blocks = [data.terraform_remote_state.infrastructure.outputs.vpc_cidr_block]
  }

  ingress {
    from_port   = 4443
    protocol    = "TCP"
    to_port     = 4443
    cidr_blocks = [data.terraform_remote_state.infrastructure.outputs.vpc_cidr_block]
  }

  ingress {
    from_port   = 4444
    protocol    = "TCP"
    to_port     = 4444
    cidr_blocks = [data.terraform_remote_state.infrastructure.outputs.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.ecs_service_name}-SG"
  }
}

resource "aws_alb_target_group" "ecs_app_target_group" {
  name        = "${var.ecs_service_name}-TG"
  port        = var.docker_container_port
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.infrastructure.outputs.vpc_id
  target_type = "ip"

  health_check {
    path                = "/wd/hub/status"
    protocol            = "HTTP"
    port                = 4444
    matcher             = "200"
    interval            = "60"
    timeout             = "30"
    unhealthy_threshold = "2"
    healthy_threshold   = "2"
  }

  tags = {
    Name = "${var.ecs_service_name}-TG"
  }
}

resource "aws_alb_listener_rule" "ecs_alb_listener_rule" {
  listener_arn = data.terraform_remote_state.infrastructure.outputs.ecs_alb_listener_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs_app_target_group.arn
  }

  condition {
    host_header {
      values = ["${lower(var.ecs_service_name)}.${data.terraform_remote_state.infrastructure.outputs.ecs_domain_name}"]
    }
  }
}

resource "aws_cloudwatch_log_group" "hub_log_group" {
  name = "${var.ecs_service_name}-LogGroup"
}

resource "aws_service_discovery_private_dns_namespace" "selenium_namespace" {
  name        = "selenium-grid"
  description = "Private dns namespace for service discovery"
  vpc         = data.terraform_remote_state.infrastructure.outputs.vpc_id
}

resource "aws_service_discovery_service" "selenium_hub" {
  name = "selenium-hub"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.selenium_namespace.id

    dns_records {
      ttl  = 60
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}