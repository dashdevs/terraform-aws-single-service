variable "deployment_document" {
  type = string
}

variable "docker_image" {
  type = string
}

variable "application_name" {
  type = string
}

variable "application_ports" {
  type    = string
  default = null
}

variable "application_env" {
  type    = map(string)
  default = {}
}

variable "application_network" {
  type    = string
  default = null
}

variable "application_configs" {
  type = map(object({
    path    = string
    content = string
  }))
  default = {}
}

variable "application_cmd" {
  type    = string
  default = null
}

variable "target_ref" {
  type = string
}

variable "target_type" {
  type = string
  validation {
    condition     = contains(["instance_id", "autoscaling_group_name"], var.target_type)
    error_message = "target_type must be either 'instance_id' or 'autoscaling_group_name'"
  }
  default = "instance_id"
}
