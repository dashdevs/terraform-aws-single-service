data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_event_rule" "ecr_image_action" {
  name        = "${var.name}-pull-image-from-ECR"
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
  name        = "${var.name}-start-autoscale-instance"
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
  target_id = "${var.name}-ecr-push"
  rule      = aws_cloudwatch_event_rule.ecr_image_action.name
  arn       = var.deployment_document
  role_arn  = aws_iam_role.ssm_lifecycle.arn

  run_command_targets {
    key    = "tag:Name"
    values = ["${var.instance_name}"]
  }
}

resource "aws_cloudwatch_event_target" "start_instance_target" {
  count     = var.autoscaling_group != null ? 1 : 0
  target_id = "${var.name}-start-instance"
  rule      = aws_cloudwatch_event_rule.instance_start_action[0].name
  arn       = var.deployment_document
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
    resources = [var.deployment_document]
  }
}

resource "aws_iam_role" "ssm_lifecycle" {
  name               = "${var.name}-SSMLifecycle"
  assume_role_policy = data.aws_iam_policy_document.ssm_lifecycle_trust.json
}

resource "aws_iam_policy" "ssm_lifecycle" {
  name   = "${var.name}-SSMLifecycle"
  policy = data.aws_iam_policy_document.ssm_lifecycle.json
}

resource "aws_iam_role_policy_attachment" "ssm_lifecycle" {
  policy_arn = aws_iam_policy.ssm_lifecycle.arn
  role       = aws_iam_role.ssm_lifecycle.name
}
