#!/bin/sh
AWS_ACCOUNT_ID="0123456789"
REGION="us-east-1"
SERVICE_NAME="selenium/node-chrome"
SERVICE_TAG="127.0"
ECR_REPO_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${SERVICE_NAME}"

# docker build
if [ "$1" = "build" ];then
    aws ecr create-repository --repository-name ${SERVICE_NAME:?} --region ${REGION} || true
    aws ecr get-login-password \
    --region ${REGION} \
    | docker login \
    --username AWS \
    --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

    docker pull ${SERVICE_NAME}:${SERVICE_TAG}
    docker tag ${SERVICE_NAME}:${SERVICE_TAG} ${ECR_REPO_URL}:${SERVICE_TAG}
    docker push ${ECR_REPO_URL}:${SERVICE_TAG}
elif [ "$1" = "plan" ];then
    terraform init -backend-config="node.config"
    terraform plan -var "docker_image_url=$ECR_REPO_URL:$SERVICE_TAG"
elif [ "$1" = "deploy" ];then
    terraform init -backend-config="node.config"
    terraform apply -var "docker_image_url=$ECR_REPO_URL:$SERVICE_TAG" -auto-approve
elif [ "$1" = "destroy" ];then
    terraform init -backend-config="node.config"
    terraform destroy -var "docker_image_url=$ECR_REPO_URL:$SERVICE_TAG" -auto-approve
fi
