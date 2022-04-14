variable "vpc_configs" {
  description = "The configs of the VPC"
  type        = any
  default     = {}
}

variable "nginx_instance_configs" {
  description = "The configs of the nginx_instnce"
  type        = any
  default     = {}
}

variable "nginx_sg_configs" {
  description = "The configs of the new VPC"
  type        = any
  default     = {}
}
