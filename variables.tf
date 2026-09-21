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

variable "applications_config" {
  type = map(object({
    flags   = optional(string, null)
    ports   = optional(string, null)
    env     = optional(map(string), {})
    cmd     = optional(string, null)
    network = optional(string, null)
    volumes = optional(list(string), [])
    tag     = optional(string, "latest")
    configs = optional(map(object({
      path    = string
      content = string
    })), {})
    additional_containers = optional(map(object({
      cmd     = string
      flags   = optional(string, null)
      ports   = optional(string, null)
      env     = optional(map(string), {})
      network = optional(string, null)
      volumes = optional(list(string), [])
      configs = optional(map(object({
        path    = string
        content = string
      })), {})
    })), {})
  }))
  default = { core = { ports = "80:8080" } }

  validation {
    condition = (
      length(distinct(flatten([
        for name, cfg in var.applications_config : concat(
          [name], [for cname in keys(cfg.additional_containers) : "${name}-${cname}"]
        )
      ])))
      ==
      length(var.applications_config) + length(flatten([
        for cfg in values(var.applications_config) : keys(cfg.additional_containers)
      ]))
    )
    error_message = "Deployment names must be unique: every application name and every \"<application>-<additional container>\" combination share one namespace. Rename the colliding application or additional container."
  }
}
