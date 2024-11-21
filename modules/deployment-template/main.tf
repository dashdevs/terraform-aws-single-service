data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  container_registry = (
    var.container_registry == "ecr" ?
    "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com" :
    ""
  )

  docker_login = (
    var.container_registry == "ecr" ?
    join(" | ", [
      "aws ecr get-login-password --region ${data.aws_region.current.name}",
      "docker login --username AWS --password-stdin ${local.container_registry}"
    ]) :
    ""
  )
}

resource "aws_ssm_document" "docker_deployment" {
  name            = "${var.name}-ssm-delivery-script"
  document_format = "YAML"
  document_type   = "Command"
  target_type     = "/AWS::EC2::Instance"

  content = templatefile("${path.module}/deployment.yaml", {
    login_command = local.docker_login
  })
}
