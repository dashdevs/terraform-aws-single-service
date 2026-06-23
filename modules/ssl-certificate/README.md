# terraform-aws-single-service-ssl


## Usage


**IMPORTANT:** We do not pin modules to versions in our examples because of the
difficulty of keeping the versions in the documentation in sync with the latest released versions.
We highly recommend that in your code you pin the version to the exact version you are
using so that your infrastructure remains stable, and update versions in a
systematic way so that they do not catch you by surprise.

### example:
```
module "certificete" {
  source             = "dashdevs/single-service/aws//modules/ssl_certificate"
  domain_name        = var.domain_name
  domain_zone_name   = var.domain_zone_name
  create_dns_records = true
  is_virginia_region = true
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
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The name of the domain for which the SSL certificate will be created. | `string` | `n/a` | yes |
| <a name="input_domain_zone_name"></a> [domain\_zone\_name](#input\_domain\_zone\_name) | The name of the domain zone in which DNS records will be created for certificate validation. Must be specified if [create\_dns\_records](#input\_create\_dns\_records) is `true`| `string` | `null` | no |
| <a name="input_create_dns_records"></a> [create\_dns\_records](#input\_create\_dns\_records) | Determines whether DNS records will be created to validate the certificate. | `string` | `false` | no |
| <a name="input_is_virginia_region"></a> [is\_virginia\_region](#input\_is\_virginia\_region) | Determines in which region the certificate will be created. If true, the certificate will be created in the Virginia region. Required true for the Cloudfront service or services that use Cloudfront for domain binding. | `string` |`false`| no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ssl_certificate_arn"></a> [ssl\_certificate\_arn](#output\_ssl\_certificate\_arn) | Unique identifier of the ssl certificate |
| <a name="output_ssl_certificate_validation_dns_records"></a> [ssl\_certificate\_validation\_dns\_records](#output\_ssl\_certificate\_validation\_dns\_records) | List of text expressions of the certificate validation DNS records to create this records manually. Required if [create\_dns\_records](#input\_create\_dns\_records) is `false` |