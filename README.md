# Selenium grid using AWS ECS Fargate
This repository sets up a scalable Selenium Grid on AWS using ECS and Terraform. The execution steps are structured as follows: first, provision the infrastructure, then deploy the Hub, and finally the Nodes.

# Project Structure
The project is divided into three main components, each serving a specific purpose:
1.	**Infrastructure:** Sets up the core AWS resources necessary for the Selenium Grid to function.
2.	**Hub:** Configures the Selenium Hub, which serves as the central point for managing browser nodes.
3.	**Node:** Deploys browser nodes (Chrome) that execute the tests.

Before diving into the setup, ensure you have the following prerequisites:
-	A registered domain name for your application.
-	An S3 bucket configured for storing Terraform state files.
-	AWS CLI installed and configured with appropriate credentials.
-	Terraform installed on your local machine.
-	Docker installed for building images.

# Key Components
## 1. Infrastructure
The Infrastructure component establishes the foundational AWS resources:
-	**VPC:** Create a Virtual Private Cloud (VPC) with two public subnets across different availability zones to ensure high availability.
-	**Security Groups:** Define security groups for the Application Load Balancer (ALB) and ECS tasks to control traffic flow.
-	**ECS Cluster:** Set up an ECS cluster that utilizes Fargate, allowing for serverless container management.
-	**Application Load Balancer (ALB):** Configure an ALB to distribute incoming traffic to the Selenium Hub and browser nodes.
-	**SSL Certificate:** To secure your Selenium Grid, set up an SSL certificate using AWS Certificate Manager (ACM) and Route 53 for DNS validation.
-	**IAM Roles and Policies:** Define the necessary IAM roles and policies to grant permissions to ECS tasks.

## 2. Hub
The Hub component focuses on configuring the Selenium Hub:
-	**ECS Task Definition:** Create an ECS task definition that specifies how to run the Selenium Hub.
-	**Security Group for Hub:** Define the security group for the Hub, allowing it to communicate within the VPC.
-	**ECS Service:** Set up an ECS service that will manage the Hub instance, ensuring it runs continuously.
-	**Service Discovery Configuration:** Implement service discovery to enable communication between the Hub and Node components.

## 3. Node
The Node component handles the deployment of browser nodes. Each browser node connects to the Selenium Hub to execute tests.
The task definition includes an environment variable that allows the browser nodes to connect to the Selenium Hub. 
-	**SE_EVENT_BUS_HOST:** The value "selenium-hub.selenium-grid" is a combination of the service name (Selenium Hub) and the DNS namespace (selenium-grid) created in the service discovery setup. It acts as the hostname for the Selenium Hub, allowing the browser nodes to discover and connect to it.

## Setting Up the Project
1.	Clone the Repository
2.	Navigate to the Infrastructure Folder
    - cd 1-infrastructure
3.	Update Configuration Files
    - s3_bucket = "your-s3-bucket-name"
4.	Preview Changes
    - ./deploy.sh plan
5.	Deploy Infrastructure
    - ./deploy.sh deploy
6.	Build Docker Images for Hub
    - cd ../2-hub
    - ./deploy-hub.sh build
7.	Push Hub Image to ECR and Deploy
    - ./deploy-hub.sh deploy
8.	Build Docker Images for Chrome Node
    - cd ../3-node
    - ./deploy-node-chrome.sh build
9.	Push Node Image to ECR and Deploy
    - ./deploy-node-chrome.sh deploy
10.	Access the Selenium Grid via the DNS of the ALB  [https://selenium-grid.my-dns.com/ui/]










