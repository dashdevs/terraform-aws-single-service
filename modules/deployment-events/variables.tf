variable "name" {
  type = string
}

variable "deployment_association_ids" {
  type = list(string)
}

variable "deployment_run_document_arn" {
  type = string
}

variable "repository_name" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "latest"
}
