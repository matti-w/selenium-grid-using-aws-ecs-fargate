variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  default = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  default = "10.0.2.0/24"
}

variable "internet_cidr_block" {
  default = "0.0.0.0/0"
}

variable "ecs_cluster_name" {
  default = "Selenium-Grid-ECS-Cluster"
}

variable "ecs_domain_name" {
  default = "my-domain.com"
}