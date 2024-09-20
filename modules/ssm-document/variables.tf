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

variable "deployment_document" {
  type = string
}
