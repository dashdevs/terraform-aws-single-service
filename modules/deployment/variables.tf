variable "name" {
  type = string
}

variable "image_name" {
  type = string
}

variable "application_name" {
  type    = string
  default = "core"
}

variable "application_ports" {
  type    = string
  default = "80:8080"
}

variable "application_env" {
  type    = map(string)
  default = {}
}

variable "application_cmd" {
  type    = string
  default = null
}

variable "container_registry" {
  type = string
  validation {
    condition     = contains(["ecr", "dockerhub"], var.container_registry)
    error_message = "container_registry must be either 'ecr' or 'dockerhub'"
  }
  default = "ecr"
}
