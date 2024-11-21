data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


locals {
  # Workaround for an issue where the aws_ssm_document data source
  # data "aws_ssm_document" "refresh_association" { name = "AWS-RefreshAssociation" }
  # returns only the document name instead of the full ARN
  # https://github.com/hashicorp/terraform-provider-aws/issues/33436
  refresh_association_document_arn = "arn:aws:ssm:${data.aws_region.current.name}::document/AWS-RefreshAssociation"
}

resource "aws_cloudwatch_event_rule" "ecr_image_action" {
  name        = "${var.name}-pull-image-from-ECR"
  description = "Rule to run ssm command on Linux server - pull image from ECR"

  event_pattern = jsonencode({
    source      = ["aws.ecr"]
    detail-type = ["ECR Image Action"]
    detail = {
      action-type     = ["PUSH"]
      result          = ["SUCCESS"]
      repository-name = ["${var.repository_name}"]
      image-tag       = ["latest"]
    }
  })
}

resource "aws_cloudwatch_event_target" "ecr_push_target" {
  rule     = aws_cloudwatch_event_rule.ecr_image_action.name
  arn      = local.refresh_association_document_arn
  input    = "{\"associationIds\":[\"${var.deployment_association_id}\"]}"
  role_arn = aws_iam_role.ssm_lifecycle.arn

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
    resources = [local.refresh_association_document_arn]
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
