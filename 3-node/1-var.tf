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
  default = "node-chrome"
}

variable "memory" {
  description = "Memory for selenium/node-chrome container"
  default     = 1024
}
variable "docker_container_port" {
  description = "Port number for selenium/node-chrome"
  default     = 5555
}
variable "desired_task_number" {
  description = "Desired task numbers for selenium/node-chrome"
  default     = 3
}

variable "docker_image_url" {
  description = "AWS ECR url for selenium/node-chrome"
}