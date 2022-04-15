# Add time sleep before fetching the welcome page
# Ensure the server is provisioned
resource "time_sleep" "wait_5_minutes" {
  depends_on = [
    module.nginx_instance, aws_security_group.nginx_sg
  ]

  create_duration = "5m"
}

data "http" "website_content" {
  url = "http://${module.nginx_instance.public_dns}"

  depends_on = [
    time_sleep.wait_5_minutes
  ]
}

output "nginx_instance_dns" {
  description = "The Public IPv4 DNS of the NGINX instance"
  value       = module.nginx_instance.public_dns
}

output "nginx_instance_ip" {
  description = "The Public IPv4 address of the NGINX instance"
  value       = module.nginx_instance.public_ip
}

output "nginx_welcome_page" {
  description = "The NGINX welcome page content"
  value       = data.http.website_content.body
}