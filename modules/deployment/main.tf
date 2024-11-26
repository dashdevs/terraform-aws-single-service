locals {
  docker_ports = var.application_ports == null ? "" : "-p ${var.application_ports}"
  docker_env   = join(" ", [for name, value in var.application_env : "-e ${name}=${value}"])
  docker_cmd   = var.application_cmd == null ? "" : var.application_cmd

  target_key = lookup({
    instance_id            = "InstanceIds"
    autoscaling_group_name = "tag:aws:autoscaling:groupName"
  }, var.target_type)
}

resource "aws_ssm_association" "deployment" {
  name = var.deployment_document

  parameters = {
    image = var.docker_image
    name  = var.application_name
    ports = local.docker_ports
    env   = local.docker_env
    cmd   = local.docker_cmd
  }

  targets {
    key    = local.target_key
    values = [var.target_ref]
  }
}
