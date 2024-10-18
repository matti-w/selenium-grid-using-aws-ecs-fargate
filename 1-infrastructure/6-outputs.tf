output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnets" {
  value = tolist([aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id])
}

output "ecs_alb_listener_arn" {
  value = aws_alb_listener.ecs_alb_https_listener.arn
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.fargate-cluster.name
}

output "ecs_domain_name" {
  value = var.ecs_domain_name
}