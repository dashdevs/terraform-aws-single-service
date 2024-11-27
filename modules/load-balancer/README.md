# terraform-aws-single-service-load-balancer


## Usage


**IMPORTANT:** We do not pin modules to versions in our examples because of the
difficulty of keeping the versions in the documentation in sync with the latest released versions.
We highly recommend that in your code you pin the version to the exact version you are
using so that your infrastructure remains stable, and update versions in a
systematic way so that they do not catch you by surprise.

### example:
```
module "load_balancer" {
  source            = "dashdevs/single-service/aws//modules/load-balancer"
  name              = var.name_prefix
  vpc_id            = var.vpc_id
  lb_subnets        = var.private_subnets
  lb_listener_ports = ["80"]
  lb_target_ports   = ["80"]
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
| <a name="input_name"></a> [name](#input\_name) | Is used to create names for all internal resources of a module. It represents a prefix that will be added to the names of all internal resources to ensure their uniqueness within the module.| `string` | `n/a` | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Identifier of the VPC to which the internal resources will be connected | `string` | `n/a` | yes |
| <a name="input_lb_subnets"></a> [lb\_subnets](#input\_lb\_subnets) | List of subnet identifiers to which the internal resources will be connected | `list(string)` | `n/a` | yes |
| <a name="input_ec2_instance_id"></a> [ec2\_instance\_id](#input\_ec2\_instance\_id) | EC2 Instance identifier that should be attached to loadbalancer | `string` |`null`| no |
| <a name="input_is_lb_internal"></a> [is\_lb\_internal](#input\_is\_lb\_internal) | Used to determine whether a load balancer is internal or external | `bool` |`false`| no |
| <a name="input_lb_listener_ports"></a> [lb\_listener\_ports](#input\_lb\_listener\_ports) | List of ports that are configured for load balancer listeners | `list(number)` | `n/a` | yes |
| <a name="input_lb_target_ports"></a> [lb\_target\_ports](#input\_lb\_target\_ports) | List of ports that are configured for load balancer target group | `list(number)` | `n/a` | yes |
| <a name="input_target_health_check_path"></a> [target\_health\_check\_path](#input\_target\_health\_check\_path) | The path that is used for health checks on the target | `string` |`/health`| no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_target_group_arns"></a> [lb\_target\_group\_arns](#output\_lb\_target\_group\_arns) | The list of target group arns that will be attached to the load balancer |
| <a name="output_lb_listener_arn"></a> [lb\_listener\_arn](#output\_lb\_listener\_arn) | The listener identifier that will be attached to the loadbalancer|
