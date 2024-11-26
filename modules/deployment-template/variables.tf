variable "name" {
  type = string
}

variable "container_registry" {
  type = string
  validation {
    condition     = contains(["ecr", "dockerhub"], var.container_registry)
    error_message = "container_registry must be either 'ecr' or 'dockerhub'"
  }
  default = "ecr"
}
