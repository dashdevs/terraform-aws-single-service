# terraform-aws-single-automations

Terraform module which creates and manages AWS Systems Manager Automation documents.

## Usage

```
module "automations" {
  source = "dashdevs/single-service/aws//modules/automations"
  name   = "my-project"
}
```

To use this module in conjunction with the `deployment-events` module:

```
module "automations" {
  source = "dashdevs/single-service/aws//modules/automations"
  name   = "my-project"
}

module "deployment_events" {
  source                      = "dashdevs/single-service/aws//modules/deployment-events"
  name                        = "my-project-core-app"
  deployment_association_id   = module.deployment.ssm_association_id
  deployment_run_document_arn = module.automations.association_start_document_arn
  repository_name             = "my-project/core-app"
}
```

This example shows how the automation document is used by the `deployment-events` module to start an AWS SSM association. For example, it can be triggered when an image is pushed to an ECR repository.

<!-- markdownlint-restore -->
<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.34 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.34 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Prefix used to generate names for the automation documents | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_association_start_document_arn"></a> [association\_start\_document\_arn](#output\_association\_start\_document\_arn) | ARN of the automation document for starting SSM associations |
