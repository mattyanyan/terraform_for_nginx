#!/bin/bash

# Review and apply the infrastucture
echo -e "Initiate Terraform environment...\n"
terraform init

echo -e "\nStart applying Terraform infrasturcture...\n"
terraform apply
nginx_instance_dns=$(terraform output | grep nginx_instance_dns | awk -F ' = ' '{print $2}' | tr -d '\"')
if [ -n $nginx_instance_dns ] ; then
    echo "Unable to fetch the NGINX instance DNS"
    exit 1
fi

# Fetch the NGINX welcome page and count word frequency
echo -e "\nFetching the NGINX welcome page...\n"
curl -s $nginx_instance_dns | xmlstarlet sel -t -v "//body"
echo -e "\nCounting the word frequency of the welcome page...\n"
curl -s $nginx_instance_dns | xmlstarlet sel -t -v "//body" | tr '[:punct:]' ' ' | tr ' ' '\n' | awk 'NF' | sort | uniq -c