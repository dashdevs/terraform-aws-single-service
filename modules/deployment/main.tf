data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  container_registry = (
    var.container_registry == "ecr" ?
    "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com" :
    ""
  )

  docker_image = (
    var.container_registry == "ecr" ? "${local.container_registry}/${var.image_name}" : "${var.image_name}"
  )

  docker_login = (
    var.container_registry == "ecr" ?
    join(" | ", [
      "aws ecr get-login-password --region ${data.aws_region.current.name}",
      "docker login --username AWS --password-stdin ${local.container_registry}"
    ]) :
    ""
  )

  docker_ports = var.application_ports == "" ? "" : "-p ${var.application_ports}"
  docker_env   = join(" ", [for env_var in var.application_env : "-e ${env_var.name}=${env_var.value}"])
  docker_cmd   = var.application_cmd == null ? "" : var.application_cmd
}

resource "aws_ssm_document" "docker_deployment" {
  name            = "${var.name}-${var.application_name}-ssm-delivery-script"
  document_format = "YAML"
  document_type   = "Command"
  target_type     = "/AWS::EC2::Instance"

  content = templatefile("${path.module}/deployment.yaml", {
    name  = var.application_name
    image = local.docker_image
    ports = local.docker_ports
    env   = local.docker_env
    cmd   = local.docker_cmd

    login_command = local.docker_login
  })
}
