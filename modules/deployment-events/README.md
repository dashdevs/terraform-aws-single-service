# terraform-aws-single-deployment-events

Terraform module to configure deployment event rules, enabling automated triggers for starting AWS SSM associations, for example, when an image is pushed to an ECR repository.

## Usage

This example shows how to use the deployment-events module in conjunction with the `deployment-template` and `deployment` modules to trigger a deployment automation when a container image is pushed to an ECR repository.

```
module "automations" {
  source = "dashdevs/single-service/aws//modules/automations"
  name   = "my-project"
}

module "deployment" {
  source              = "dashdevs/single-service/aws//modules/deployment"
  deployment_document = "MyDeploymentDocument"
  docker_image        = "my-docker-image"
  application_name    = "core-app"
  application_ports   = "8080:80 9090:90"
  application_env      = { ENV_VAR1 = "value1", ENV_VAR2 = "value2" }
  application_cmd     = "npm start"
  target_ref          = "my-autoscaling-group"
  target_type         = "autoscaling_group_name"
}

module "deployment_events" {
  source                      = "dashdevs/single-service/aws//modules/deployment-events"
  name                        = "my-project-core-app"
  deployment_association_id   = module.deployment.ssm_association_id
  deployment_run_document_arn = module.automations.association_start_document_arn
  repository_name             = "my-project/core-app"
}
```

<!-- markdownlint-restore -->
<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.78 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.78 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Prefix for naming the deployment-related resources | `string` | n/a | yes |
| <a name="input_deployment_association_id"></a> [deployment\_association\_id](#input\_deployment\_association\_id) | ID of the SSM association to be triggered by the event rules | `string` | n/a | yes |
| <a name="input_deployment_run_document_arn"></a> [deployment\_run\_document\_arn](#input\_deployment\_run\_document\_arn) | ARN of the SSM document that triggers the deployment automation, specifically to start SSM associations | `string` | n/a | yes |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | Name of the repository whose events trigger the deployment rules | `string` | n/a | yes |

## Outputs

No outputs.
