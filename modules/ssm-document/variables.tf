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
  type    = string
  default = null
}

variable "application_ports" {
  type    = string
  default = "80:8080"
}

variable "application_name" {
  type    = string
  default = "core"
}

variable "application_start_command" {
  type    = string
  default = null
}

variable "application_env_vars" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "application_external_docker_image" {
  type    = string
  default = null
}
