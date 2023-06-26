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
