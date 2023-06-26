variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "lb_subnets" {
  type = list(string)
}

variable "ec2_instance_id" {
  type    = string
  default = null
}

variable "is_lb_internal" {
  type    = bool
  default = true
}

variable "lb_listener_ports" {
  type = list(number)
}

variable "lb_target_ports" {
  type = list(number)
}

variable "target_health_check_path" {
  type    = string
  default = "/health"
}
