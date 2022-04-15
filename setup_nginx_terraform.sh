#!/bin/bash

print_with_color () {
    if [ "$1" = "magenta" ] ; then
        echo -e "\e[1;35m $2 \e[0m"
    elif [ "$1" = "red" ] ; then
        echo -e "\e[1;31m $2 \e[0m"
    elif [ "$1" = "green" ] ; then
        echo -e "\e[1;32m $2 \e[0m"
    fi
}

# Review and apply the infrastucture
print_with_color "magenta" "Initiate Terraform environment...\n"
terraform init

print_with_color "magenta" "\nStart applying Terraform infrasturcture...\n"
terraform apply
nginx_instance_dns=$(terraform output | grep nginx_instance_dns | awk -F ' = ' '{print $2}' | tr -d '\"')
if [ -z "$nginx_instance_dns" ] ; then
    print_with_color "red" "Unable to fetch the NGINX instance DNS"
    exit 1
fi

# Fetch the NGINX welcome page and count word frequency
print_with_color "magenta" "\nFetching the NGINX welcome page...\n"
curl -s $nginx_instance_dns | xmlstarlet sel -t -v "//body"
print_with_color "magenta" "\nCounting the word frequency of the welcome page...\n"
curl -s $nginx_instance_dns | xmlstarlet sel -t -v "//body" | tr '[:punct:]' ' ' | tr ' ' '\n' | awk 'NF' | sort | uniq -c

print_with_color "green" "\nInfrastructure is provisioned\n"