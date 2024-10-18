#!/bin/sh

if [ "$1" = "plan" ];then
    terraform init -backend-config="infra.config"
    terraform plan
elif [ "$1" = "deploy" ];then
    terraform init -backend-config="infra.config"
    terraform apply -auto-approve
elif [ "$1" = "destroy" ];then
    terraform init -backend-config="infra.config"
    terraform destroy -auto-approve
fi
