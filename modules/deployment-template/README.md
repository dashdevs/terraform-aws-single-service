# terraform-aws-single-deployment-template

Terraform module that creates an AWS SSM document for Docker-based application deployment.

## Usage

```
module "deployment_template" {
  source             = "dashdevs/single-service/aws//modules/deployment-template"
  name               = "my-dockerhub-deployment-template"
  container_registry = "dockerhub"
}
```

To use this module in conjunction with the `deployment` module:

```
module "deployment_template" {
  source = "dashdevs/single-service/aws//modules/deployment-template"
  name   = "my-ecr-deployment-template"
}

module "deployment" {
  source              = "dashdevs/single-service/aws//modules/deployment"
  deployment_document = module.deployment_template.ssm_document_name
  docker_image        = "my-docker-image"
  application_name    = "my-application"
  application_ports   = "8080:80 9090:90"
  application_env     = { ENV_VAR1 = "value1", ENV_VAR2 = "value2" }
  application_cmd     = "npm start"
  target_ref          = "my-autoscaling-group"
  target_type         = "autoscaling_group_name"
}
```

This example creates an SSM document for Docker-based deployment and uses it to deploy an application to an Auto Scaling group. The deployment document automates tasks like Docker login, image pulling, and container startup, while the deployment module associates the document with the specified target.

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
| <a name="input_name"></a> [name](#input\_name) | Name of the SSM document for the Docker-based deployment | `string` | n/a | yes |
| <a name="input_container_registry"></a> [container\_registry](#input\_container\_registry) | Type of container registry used. Must be either `ecr` or `dockerhub` | `string` | `"ecr"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ssm_document_arn"></a> [ssm\_document\_arn](#output\_ssm\_document\_arn) | ARN of the created SSM document |
| <a name="output_ssm_document_name"></a> [ssm\_document\_name](#output\_ssm\_document\_name) | Name of the created SSM document |
