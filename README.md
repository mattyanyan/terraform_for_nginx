# Terraform for NGINX

Terraform for NGINX is a project for provisioning NGINX server in AWS using Terraform.

## Prerequisite

Install required packages:

### Terraform

```bash
sudo apt-get update && sudo apt-get install -y gnupg \
    software-properties-common \
    curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```

### XMLStarlet

```bash
sudo apt-get update && sudo apt-get install -y xmlstarlet
```

### AWS CLI v2

Please follow the official AWS CLI setup guideline to setup AWS CLI on your machine:
[https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)

### Create AWS EC2 Key Pair

```bash
aws ec2 create-key-pair --key-name ExampleKeyPair --key-type rsa
```

This part need to be done manually because Terraform does not support creating key pair at the moment. It only supports managing existing key. For more details: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair)

```bash
Currently this resource requires an existing user-supplied key pair.
```

### Docker hub account

A docker hub account is required. It is used to pull the offcial NGINX docker image. To sign up: [https://hub.docker.com/](https://hub.docker.com/)

## Setup

.tfvars files are used to set the configurations for VPC, EC2 instance, and the security groups:

### vpc_configs.auto.tfvars

```bash
vpc_configs = {
  name = "example-vpc",                  <- VPC name: string
  cidr = "10.0.0.0/16",                  <- CIDR block: string
  azs = [                                <- List of availability zone: list of string
    "ap-east-1a",
    "ap-east-1b",
    "ap-east-1c"
  ],
  enable_dns_hostnames    = true,        <- Enable dns hostnames: boolean
  map_public_ip_on_launch = true,        <- Map public IP on launch: boolean
  public_subnet_suffix    = "public",    <- Suffix of the public subnet: string
  public_subnet_tags      = {},          <- Extra tag for the public subnet: map
  public_subnets = [                     <- List of CIDR blocks of subnets: list of string
    "10.0.101.0/24",
  ],
  private_subnet_suffix = "private",     <- Suffix of the private subnet: string
  private_subnet_tags   = {},            <- Extra tag for the private subnet: map
  private_subnets       = [],            <- List of CIDR blocks of subnets: list of string
  tags                  = {},            <- Extra Tags (There are tags added by default) : map
}
```

### nginx_instance_configs.auto.tfvars

```bash
nginx_instance_configs = {
  name                        = "example-nginx-instance",  <- Instance name: string
  associate_public_ip_address = true,                      <- Associate public IP address: boolean
  instance_type               = "t3.micro",                <- Instance type: string
  key_name                    = "ExampleKeyPair",          <- Key pair name: string
  user_data                   = <<EOF                      <- User data: string
#!/bin/bash
yum update -y
amazon-linux-extras install docker
service docker start
systemctl enable docker
usermod -a -G docker ec2-user
# replace the <docker hub username> and <password>
docker login -u <docker hub usename> -p <docker hub password>
docker pull nginx
docker run --name example-nginx -d -p 80:80 nginx
EOF
  tags                        = {},                        <- Extra Tags (There are tags added by default): map
}
```

### nginx_sg_configs.auto.tfvars

```bash
nginx_sg_configs = {
  name        = "nginx_sg",                                   <- SG name: string
  description = "The security group for the NGINX instance.", <- SG description: string
  ingress = [                                                 <- List of ingress rules: list of map
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP for NGINX server"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ],
  egress = [                                                  <- List of egress rules: list of maps
    {
      from_port        = 0
      to_port          = 0
      protocol         = -1
      description      = "Egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    },
  ],
  tags = {},                                                  <- Extra tags: map
}
```

### Version control of the .tfvars files

These files are included in this git only for the sake of demonstration. It is suggested to ignore them as they may contain sensitive information.

To ignore them, please uncomment the following lines in `.gitignore`.

```bash
# *.tfvars
# *.tfvars.json
```

## Usage

### Apply

```bash
./setup_nginx_terraform.sh
```

`setup_nginx_terraform.sh` is used to:

1. Init Terraform environment
2. Apply Terraform infrastructure
3. Fetch the default NGINX welcome page
4. Count the word frequencies of the welcome page

#### Sample output

```bash
$ ./setup_nginx_terraform.sh

Initiate Terraform environment...

...
...
...

Plan: 8 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + nginx_instance_dns = (known after apply)
  + nginx_instance_ip  = (known after apply)
  + nginx_welcome_page = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

...
...
...

Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

...
...
...

Fetching the NGINX welcome page...


Welcome to nginx!
If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.

For online documentation and support please refer to
nginx.org.
Commercial support is available at
nginx.com.

Thank you for using nginx.

Counting the word frequency of the welcome page...

      1 Commercial
      1 For
      1 Further
      1 If
      1 Thank
      1 Welcome
      2 and
      1 at
      1 available
      1 com
      1 configuration
      1 documentation
      1 for
      1 installed
      3 is
      5 nginx
      1 online
      1 org
      1 page
      1 please
      1 refer
      1 required
      1 see
      1 server
      1 successfully
      2 support
      1 the
      1 this
      2 to
      1 using
      1 web
      1 working
      2 you
```

### Destroy

```bash
terraform destroy
```
