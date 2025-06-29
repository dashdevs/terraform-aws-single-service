# terraform-aws-single-deployment

Terraform module which creates and manages AWS SSM associations for application deployment.

## Usage

To deploy an application to an Auto Scaling group, use the following configuration:

```
module "deployment" {
  source              = "dashdevs/single-service/aws//modules/deployment"
  deployment_document = "MyDeploymentDocument"
  docker_image        = "my-docker-image"
  docker_run_flags    = "--rm"
  application_name    = "my-application"
  application_ports   = "8080:80 9090:90"
  application_env     = { ENV_VAR1 = "value1", ENV_VAR2 = "value2" }
  application_cmd     = "npm start"
  application_network = "my-network"
  application_volumes = ["/data:/data"]
  application_configs = {
    "config.json" = {
      path    = "/app/config/config.json"
      content = jsonencode({ key = "value" })
    }
  }
  target_ref  = "my-autoscaling-group"
  target_type = "autoscaling_group_name"
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
| <a name="input_deployment_document"></a> [deployment\_document](#input\_deployment\_document) | Name of the SSM document (command) that performs the deployment. The document must define parameters for `image`, `name`, `flags`, `files`, `ports`, `env`, `network`, `volumes`, and `cmd` to configure Docker-based deployments | `string` | n/a | yes |
| <a name="input_docker_image"></a> [docker\_image](#input\_docker\_image) | Docker image to deploy | `string` | n/a | yes |
| <a name="input_docker_run_flags"></a> [docker\_run\_flags](#input\_docker\_run\_flags) | Additional flags to be passed to docker run (e.g., `--rm`, `--restart always`). If null, the default `--restart unless-stopped` will be used | `string` | `null` | no |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application being deployed | `string` | n/a | yes |
| <a name="input_application_ports"></a> [application\_ports](#input\_application\_ports) | Ports to expose for the application, specified in the format host_port:container_port (e.g., `8080:80 9090:90`) | `string` | `null` | no |
| <a name="input_application_env"></a> [application\_env](#input\_application\_env) | Environment variables for the application in key-value pairs | `map(string)` | `{}` | no |
| <a name="input_application_cmd"></a> [application\_cmd](#input\_application\_cmd) | Command to run the application inside the Docker container | `string` | `null` | no |
| <a name="input_application_network"></a> [application\_network](#input\_application\_network) | Docker network to connect the container to | `string` | `null` | no |
| <a name="input_application_volumes"></a> [application\_volumes](#input\_application\_volumes) | List of Docker volume mappings (`host_path:container_path`) | `list(string)` | `[]` | no |
| <a name="input_application_configs"></a> [application\_configs](#input\_application\_configs) | Map of configuration files to create before starting the container | `map(object({ path = string, content = string }))` | `{}` | no |
| <a name="input_target_ref"></a> [target\_ref](#input\_target\_ref) | Identifier of the deployment target (e.g., an instance ID or an Auto Scaling group name) | `string` | n/a | yes |
| <a name="input_target_type"></a> [target\_type](#input\_target\_type) | Type of the deployment target, either `instance_id` or `autoscaling_group_name` | `string` | `"instance_id"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ssm_association_id"></a> [ssm\_association\_id](#output\_ssm\_association\_id) | ID of the created SSM association |
