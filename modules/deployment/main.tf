locals {
  docker_ports = var.application_ports == null ? null : "-p ${var.application_ports}"

  docker_env = length(var.application_env) > 0 ? join(
    " ", [for name, value in var.application_env : "-e ${name}=${value}"]
  ) : null

  config_mappings = [for name, config in var.application_configs : {
    file   = "${name}:${base64encode(config.content)}"
    volume = "/srv/docker/${var.application_name}/${name}:${config.path}"
  }]
  config_files = length(local.config_mappings) > 0 ? join(",", local.config_mappings[*].file) : null

  docker_volumes = length(local.config_mappings) > 0 || length(var.application_volumes) > 0 ? join(
    " ", formatlist("-v %s", concat(local.config_mappings[*].volume, var.application_volumes))
  ) : null

  target_key = lookup({
    instance_id            = "InstanceIds"
    autoscaling_group_name = "tag:aws:autoscaling:groupName"
  }, var.target_type)
}

resource "aws_ssm_association" "deployment" {
  name = var.deployment_document

  parameters = {
    image   = var.docker_image
    name    = var.application_name
    flags   = var.docker_run_flags
    files   = local.config_files
    ports   = local.docker_ports
    env     = local.docker_env
    network = var.application_network
    volumes = local.docker_volumes
    cmd     = var.application_cmd
  }

  targets {
    key    = local.target_key
    values = [var.target_ref]
  }
}
