# terraform-aws-single-service


## Usage


**IMPORTANT:** We do not pin modules to versions in our examples because of the
difficulty of keeping the versions in the documentation in sync with the latest released versions.
We highly recommend that in your code you pin the version to the exact version you are
using so that your infrastructure remains stable, and update versions in a
systematic way so that they do not catch you by surprise.

### example for one EC instance:
```
module "admin_panel_computing" {
  source                    = "dashdevs/single-service/aws"
  name                      = var.name_prefix
  vpc_id                    = var.vpc_id
  ec2_subnets               = var.subnets
  ec2_instance_name_postfix = var.instance_name

  applications_config = {
    core = {
      ports = "80:8080"
    }
  }
}

```

### example for EC2 instance with autoscaling group:

```
module "computing" {
  source                    = "dashdevs/single-service/aws"
  name                      = var.name_prefix
  vpc_id                    = var.vpc_id
  ec2_subnets               = var.private_subnets
  ec2_instance_type         = var.ec2_instance_type
  target_group_arns         = module.load-balancer.target_group_arns
  ec2_instance_name_postfix = var.instance_name
  create_autoscaling        = true
  ec2_instance_count_max    = 2

  applications_config = {
    core = {
      ports = "80:8080"
      cmd   = null
      env = {
        example_var_name = "example_var_value"
      }
    }
  }
}
```

<!-- markdownlint-restore -->
<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.34 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.34 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) |  Is used to create names for all internal resources of a module. It represents a prefix that will be added to the names of all internal resources to ensure their uniqueness within the module. | `string` | `n/a` | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Identifier of the VPC to which the internal resources will be connected | `string` | `n/a` | yes |
| <a name="input_ec2_subnets"></a> [ec2\_subnets](#input\_ec2\_subnets) | List of subnet identifiers to which the internal resources will be connected | `list(string)` | `n/a` | yes |
| <a name="input_ec2_create_eip"></a> [ec2\_create\_eip](#input\_ec2\_create\_eip) | Used to create Elastic IP and assign to the EC2 instance | `bool` |`false`| no |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | EC2 instance type to be used. If `create_autoscaling` is enabled, this will apply to each instance in the autoscaling group | `string` | `t2.micro` | no |
| <a name="input_ec2_instance_count_min"></a> [ec2\_instance\_count\_min](#input\_ec2\_instance\_count\_min) | Minimum number of EC2 instances that should be provisioned if `create_autoscaling` is `true` | `number` |`1`| no |
| <a name="input_ec2_instance_count_max"></a> [ec2\_instance\_count\_max](#input\_ec2\_instance\_count\_max) | Maximum number of EC2 instances that should be provisioned if `create_autoscaling` is `true` | `number` |`1`| no |
| <a name="input_attach_ecr_based_deployment_policy"></a> [attach\_ecr\_based\_deployment\_policy](#input\_attach\_ecr\_based\_deployment\_policy) | If `true`, will attach ecr based deployment policy to EC2 instances | `bool` |`true`| no |
| <a name="input_iam_role_additional_policies"></a> [iam\_role\_additional\_policies](#input\_iam\_role\_additional\_policies) | List of additional policy for attach to EC2 instances | `list(string)` |`[]`| no |
| <a name="input_create_autoscaling"></a> [create\_autoscaling](#input\_create\_autoscaling) | Used to create autoscaling group. If `true`, will create autoscaling group | `bool` |`false`| no |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | Loadbalancer target group ARN list. Used for attach EC2 instance to loadbalancer, if `create_autoscaling` is `false` | `list(string)` |`[]`| no |
| <a name="input_ec2_instance_name_postfix"></a> [ec2\_instance\_name\_postfix](#input\_ec2\_instance\_name\_postfix) | A primary keyword of the instance name. The resulting instance name will consist of name prefix and instance name postfix. | `string` |`server`| no |
| <a name="input_ec2_ingress_ports"></a> [ec2\_ingress\_ports](#input\_ec2\_ingress\_ports) | The list of ports that are allowed for incoming traffic to an EC2 instance | `list(string)` |`["80", "22"]`| no |
| <a name="input_applications_config"></a> [applications\_config](#input\_applications\_config) | Applications configuration map for application name, ports, start command, and environment variables. | `map(object({ ports = optional(string, null), env = optional(map(string), {}), cmd = optional(string, null) }))` | `{"core": { "ports": "80:8080" }}` | no |


## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_instance_role"></a> [ec2\_instance\_role](#output\_ec2\_instance\_role) | The IAM role identifier assigned to the EC2 instance |
| <a name="output_ec2_ssh_keypair_value"></a> [ec2\_ssh\_keypair\_value](#output\_ec2\_ssh\_keypair\_value) | The value of the SSH key pair that will be used for EC2 instances |
| <a name="output_ec2_security_group_id"></a> [ec2\_security\_group\_id](#output\_ec2\_security\_group\_id) | The security group identifier assigned to the EC2 instance |
| <a name="output_ec2_instance_id"></a> [ec2\_instance\_id](#output\_ec2\_instance\_id) | EC2 Instance identifier |
| <a name="output_ec2_elastic_ip_address"></a> [ec2\_elastic\_ip\_address](#output\_ec2\_elastic\_ip\_address) | Elastic ip address assigned to the EC2 instance |