# Selenium grid using AWS ECS Fargate
This repository sets up a scalable Selenium Grid on AWS using ECS and Terraform. The execution steps are structured as follows: first, provision the infrastructure, then deploy the Hub, and finally the Nodes.

### Requirements
- Register a domain name.
- Create an S3 bucket for storing Terraform state files.

### Infrastructure
Contains Terraform scripts to provision the VPC, subnets, security groups, and the ECS cluster. The deploy.sh script automates infrastructure management tasks, including planning, applying, and destroying resources.

### Hub
Deploys the Selenium Hub on ECS using Fargate. The deploy-hub.sh script handles building and pushing the Docker image to ECR, preparing the Terraform plan, deploying, and tearing down the hub.

### Node
Manages the deployment of browser nodes (e.g., Chrome) on ECS. The deploy-node-chrome.sh script mirrors the hub's functionality, ensuring seamless integration with the hub and enabling scalability.
