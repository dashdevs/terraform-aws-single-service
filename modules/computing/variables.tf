variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ec2_subnets" {
  type = list(string)
}

variable "ec2_create_eip" {
  type    = bool
  default = false
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ec2_instance_count_min" {
  type    = number
  default = 1
}

variable "ec2_instance_count_max" {
  type    = number
  default = 1
}

variable "ec2_root_storage_size" {
  type    = number
  default = 8
}

variable "attach_ecr_based_deployment_policy" {
  type    = bool
  default = true
}

variable "iam_role_additional_policies" {
  type    = list(string)
  default = []
}

variable "create_autoscaling" {
  type    = bool
  default = false
}

variable "target_group_arns" {
  type    = list(string)
  default = []
}

variable "ec2_instance_name_postfix" {
  type    = string
  default = "server"
}

variable "ec2_ingress_ports" {
  type    = list(string)
  default = ["80", "22"]
}

variable "ec2_ami_id" {
  type    = string
  default = null
}

variable "ec2_user_data" {
  type    = string
  default = null
}

variable "ec2_ingress_port_restrictions" {
  type = map(object({
    cidr_blocks     = optional(list(string))
    prefix_list_ids = optional(list(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for restriction in var.ec2_ingress_port_restrictions : restriction.cidr_blocks != null || restriction.prefix_list_ids != null
    ])
    error_message = "each ec2_ingress_port_restrictions entry must set cidr_blocks or prefix_list_ids."
  }
}

variable "ec2_apply_docker_config" {
  type    = bool
  default = true
}
