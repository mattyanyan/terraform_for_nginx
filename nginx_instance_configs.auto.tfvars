nginx_instance_configs = {
  name                        = "example-nginx-instance",
  associate_public_ip_address = true,
  instance_type               = "t3.micro",
  key_name                    = "ExampleKeyPair",
  user_data                   = <<EOF
#!/bin/bash
yum update -y
amazon-linux-extras install docker
service docker start
systemctl enable docker
usermod -a -G docker ec2-user
docker login -u mattyanyan -p 24ea4835-e7c6-40ec-895a-851c552e1ec0
docker pull nginx
docker run --name welend-nginx -d -p 80:80 nginx
EOF
  tags                        = {},
}
