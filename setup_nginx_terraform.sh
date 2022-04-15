#!/bin/bash

# Install required packages
echo "Installed required packages if necessary..."
sudo apt-get update && sudo apt-get install -y gnupg \
    software-properties-common \
    curl \
    xmlstarlet
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
echo ""

# Review and apply the infrastucture
echo "Initiate Terraform environment..."
terraform init
echo "Start applying Terraform infrasturcture..."
terraform apply
nginx_instance_dns=$(terraform output | grep nginx_instance_dns | awk -F ' = ' '{print $2}' | tr -d '\"')
if [ -n $nginx_instance_dns ] ; then
    echo "Unable to fetch the NGINX instance DNS"
    exit 1
fi
echo ""

# Fetch the NGINX welcome page and count word frequency
echo "Fetching the NGINX welcome page..."
curl -s $nginx_instance_dns | xmlstarlet sel -t -v "//body"
echo ""
echo "Counting the word frequency of the welcome page..."
curl -s $nginx_instance_dns | xmlstarlet sel -t -v "//body" | tr '[:punct:]' ' ' | tr ' ' '\n' | awk 'NF' | sort | uniq -c