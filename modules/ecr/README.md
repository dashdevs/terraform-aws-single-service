# terraform-aws-single-service-ecr


## Usage


**IMPORTANT:** We do not pin modules to versions in our examples because of the
difficulty of keeping the versions in the documentation in sync with the latest released versions.
We highly recommend that in your code you pin the version to the exact version you are
using so that your infrastructure remains stable, and update versions in a
systematic way so that they do not catch you by surprise.

### example:
```
module "ecr" {
  source            = "dashdevs/single-service/aws//modules/ecr"
  name              = var.name_prefix
  application_names = var.application_names
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
| <a name="input_application_names"></a> [application\_names](#input\_application\_names) | List of docker application names. | `list(string)` | `n/a` | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repository_names"></a> [repository\_names](#output\_repository\_names) | List of docker repository full names.  |
