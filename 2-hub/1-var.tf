variable "region" {
  default = "us-east-1"
}

variable "remote_state_key" {
  default = "Grid-Infra/terraform.tfstate"
}

variable "remote_state_bucket" {
  default = "my-s3-bucket"
}

variable "ecs_service_name" {
  default = "selenium-grid"
}

variable "memory" {
  description = "Memory for Selenium/hub container"
  default     = 1024
}

variable "docker_container_port" {
  description = "Selenium/hub port number"
  default     = 4444
}

variable "desired_task_number" {
  description = "Desired task number for selenium/hub"
  default     = 1
}

variable "docker_image_url" {
  description = "AWS ECR url for selenium/hub"
}