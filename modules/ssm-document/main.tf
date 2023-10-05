data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  ports = var.application_ports != null ? "-p ${var.application_ports}" : null
  env_vars_list = [
    for env_var in var.application_env_vars : "-e ${env_var.name}=${env_var.value}"
  ]
  env_vars = length(var.application_env_vars) > 0 ? join(" ", locals.env_vars_list) : null
}

resource "aws_ssm_document" "docker" {
  name            = "${var.name}-${var.application_name}-ssm-delivery-script"
  document_format = "YAML"
  document_type   = "Command"
  target_type     = "/AWS::EC2::Instance"

  content = <<DOC
schemaVersion: '2.2'
description: Delivery Script
parameters:
  app:
    type: String
    default: "${var.application_name}"
  ports:
    type: String
    default: "${local.ports}"
  env_vars:
    type: String
    default: "${local.env_vars}"
  start_command:
    type: String
    default: "${var.application_start_command}"
mainSteps:
  - action: 'aws:runShellScript'
    name: deployApplication
    inputs:
      runCommand:
      - |
        export REGISTRY=${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com
        aws ecr get-login-password --region ${data.aws_region.current.name} | sudo docker login --username AWS --password-stdin $REGISTRY
        DOCKER_IMAGE=$REGISTRY/${var.repository_name}
        CURRENT_CONTAINER=$(docker ps -aql --filter ancestor=$DOCKER_IMAGE:latest --format='{{.ID}}')
        if [ ! -z $CURRENT_CONTAINER ]; then docker rm -f $CURRENT_CONTAINER; fi
        sudo docker image prune -a --force
        sudo docker image pull $DOCKER_IMAGE:latest
        sudo docker run --restart unless-stopped -d {{ports}} {{env_vars}} --name {{app}} $DOCKER_IMAGE:latest {{start_command}}
DOC
}

resource "aws_cloudwatch_event_rule" "ecr_image_action" {
  name        = "${var.name}-${var.application_name}-pull-image-from-ECR"
  description = "Rule to run ssm command on Linux server - pull image from ECR"

  event_pattern = jsonencode({
    detail-type = [
      "ECR Image Action"
    ]
    source = ["aws.ecr"]
    detail = {
      action-type     = ["PUSH"]
      result          = ["SUCCESS"]
      repository-name = ["${var.repository_name}"]
      image-tag       = ["latest"]
    }
  })
}

resource "aws_cloudwatch_event_rule" "instance_start_action" {
  count       = var.autoscaling_group != null ? 1 : 0
  name        = "${var.name}-${var.application_name}-start-autoscale-instance"
  description = "Rule to run ssm command on Linux server - start autoscale instance"

  event_pattern = jsonencode({
    source      = ["aws.autoscaling"]
    detail-type = ["EC2 Instance Launch Successful"]

    detail = {
      AutoScalingGroupName = [var.autoscaling_group]
    }
  })
}

resource "aws_cloudwatch_event_target" "ecr_push_target" {
  target_id = "${var.name}-${var.application_name}-ecr-push"
  rule      = aws_cloudwatch_event_rule.ecr_image_action.name
  arn       = aws_ssm_document.docker.arn
  role_arn  = aws_iam_role.ssm_lifecycle.arn

  run_command_targets {
    key    = "tag:Name"
    values = ["${var.instance_name}"]
  }
}

resource "aws_cloudwatch_event_target" "start_instance_target" {
  count     = var.autoscaling_group != null ? 1 : 0
  target_id = "${var.name}-${var.application_name}-start-instance"
  rule      = aws_cloudwatch_event_rule.instance_start_action[0].name
  arn       = aws_ssm_document.docker.arn
  role_arn  = aws_iam_role.ssm_lifecycle.arn

  run_command_targets {
    key    = "tag:Name"
    values = ["${var.instance_name}"]
  }
}

data "aws_iam_policy_document" "ssm_lifecycle_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ssm_lifecycle" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Name"
      values   = ["${var.instance_name}"]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = [aws_ssm_document.docker.arn]
  }
}

resource "aws_iam_role" "ssm_lifecycle" {
  name               = "${var.name}-${var.application_name}-SSMLifecycle"
  assume_role_policy = data.aws_iam_policy_document.ssm_lifecycle_trust.json
}

resource "aws_iam_policy" "ssm_lifecycle" {
  name   = "${var.name}-${var.application_name}-SSMLifecycle"
  policy = data.aws_iam_policy_document.ssm_lifecycle.json
}

resource "aws_iam_role_policy_attachment" "ssm_lifecycle" {
  policy_arn = aws_iam_policy.ssm_lifecycle.arn
  role       = aws_iam_role.ssm_lifecycle.name
}
