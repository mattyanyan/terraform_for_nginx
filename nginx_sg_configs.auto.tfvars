nginx_sg_configs = {
  name        = "nginx_sg",
  description = "The security group for the NGINX instance.",
  ingress = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP for NGINX server"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ],
  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = -1
      description      = "Egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    },
  ],
  tags = {},
}
