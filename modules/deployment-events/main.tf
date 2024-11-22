data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "deployment_runner_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "deployment_runner_permissions" {
  statement {
    actions = ["ssm:StartAutomationExecution"]
    resources = [
      "${var.deployment_run_document_arn}",
      "${var.deployment_run_document_arn}:*"
    ]
  }
  statement {
    actions = ["ssm:StartAssociationsOnce"]
    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:association/${var.deployment_association_id}"
    ]
  }
}


# IAM roles and policies

resource "aws_iam_role" "deployment_runner" {
  name               = "${var.name}-deployment-runner"
  assume_role_policy = data.aws_iam_policy_document.deployment_runner_trust.json
}

resource "aws_iam_policy" "deployment_runner" {
  name   = "${var.name}-deployment-runner-policy"
  policy = data.aws_iam_policy_document.deployment_runner_permissions.json
}

resource "aws_iam_role_policy_attachment" "deployment_runner" {
  role       = aws_iam_role.deployment_runner.name
  policy_arn = aws_iam_policy.deployment_runner.arn
}


# Deployment event rules

resource "aws_cloudwatch_event_rule" "ecr_push" {
  name        = "${var.name}-ecr-push"
  description = "Rule triggered by ECR image push to start SSM automation"

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

resource "aws_cloudwatch_event_target" "ecr_push_deployment_run" {
  rule     = aws_cloudwatch_event_rule.ecr_push.name
  arn      = var.deployment_run_document_arn
  input    = jsonencode({ associationId = [var.deployment_association_id] })
  role_arn = aws_iam_role.deployment_runner.arn
}
