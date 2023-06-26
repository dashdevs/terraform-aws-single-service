variable "name" {
  type = string
}

variable "autoscaling_group" {
  type    = string
  default = null
}

variable "instance_name" {
  type = string
}

variable "repository_name" {
  type = string
}

variable "application_ports" {
  type    = string
  default = "80:8080"
}

variable "application_name" {
  type    = string
  default = "core"
}
