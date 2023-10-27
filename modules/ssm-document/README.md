# terraform-aws-single-service-ssm-document


## Usage


**IMPORTANT:** We do not pin modules to versions in our examples because of the
difficulty of keeping the versions in the documentation in sync with the latest released versions.
We highly recommend that in your code you pin the version to the exact version you are
using so that your infrastructure remains stable, and update versions in a
systematic way so that they do not catch you by surprise.

### example:
```
module "ssm-document" {
  source            = "dashdevs/single-service/aws//modules/ssm-document"
  name              = var.name_prefix
  autoscaling_group = module.ec2.autoscaling_group
  instance_name     = module.ec2.ec2_instance_name
  repository_name   = var.ecr_name
  application_name  = var.application_name
  application_ports = var.application_ports
  application_env_vars = [
    {
      name = "example_var_name"
      value = "example_var_value"
    }
  ]
}

```

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
| <a name="input_name"></a> [name](#input\_name) | Is used to create names for all internal resources of a module. It represents a prefix that will be added to the names of all internal resources to ensure their uniqueness within the module. | `string` | `n/a` | yes |
| <a name="input_autoscaling_group"></a> [autoscaling\_group](#input\_autoscaling\_group) | The name of the autoscaling group that will be monitored by Cloudwatch to run the SSM command on scaling events. | `string` | `null` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Instance tag Name value for target ssm document | `string` | `n/a` | yes |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | Name for AWS docker repository for ssm document | `string` |`yes`| no |
| <a name="input_application_ports"></a> [application\_ports](#input\_application\_ports) | Application ports in the ssm document | `string` | `80:8080` | no |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Application name in the ssm document | `string` | `core` | no |
| <a name="input_application_start_command"></a> [application\_start\_command](#input\_application\_start\_coommand) | Application Docker endpoint in the ssm document | `string` | `null` | no |
| <a name="input_application_env_vars"></a> [application\_env\_vars](#input\_application\_env\_vars) | List of map of the application environment variables in the ssm document. Wher `name` it is the variable name and `value` it is the variable value | `list(object{name = string, value = string})` | `[]` | no |
| <a name="input_application_external_docker_image"></a> [application\_external\_docker\_image](#input\_application\_external\_docker\_image) | The docker image name from external docker repository | `string` |`null`| no |

## Outputs

| Name | Description |
|------|-------------|

