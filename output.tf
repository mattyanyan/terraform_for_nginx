output "nginx_instance_dns" {
  description = "The Public IPv4 DNS of the NGINX instance"
  value       = module.nginx_instance.public_dns
}

output "nginx_instance_ip" {
  description = "The Public IPv4 address of the NGINX instance"
  value       = module.nginx_instance.public_ip
}