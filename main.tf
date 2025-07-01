module "container_registry" {
  source            = "./modules/container-registry"
  name              = var.name
  application_names = keys(var.applications_config)
}

module "computing" {
  source                             = "./modules/computing"
  name                               = var.name
  vpc_id                             = var.vpc_id
  ec2_subnets                        = var.ec2_subnets
  ec2_create_eip                     = var.ec2_create_eip
  ec2_instance_type                  = var.ec2_instance_type
  create_autoscaling                 = var.create_autoscaling
  ec2_instance_count_min             = var.ec2_instance_count_min
  ec2_instance_count_max             = var.ec2_instance_count_max
  ec2_root_storage_size              = var.ec2_root_storage_size
  attach_ecr_based_deployment_policy = var.attach_ecr_based_deployment_policy
  iam_role_additional_policies       = var.iam_role_additional_policies
  target_group_arns                  = var.target_group_arns
  ec2_instance_name_postfix          = var.ec2_instance_name_postfix
  ec2_ingress_ports                  = var.ec2_ingress_ports
}

module "deployment_template" {
  source = "./modules/deployment-template"
  name   = "${var.name}-deployment"
}

module "deployment" {
  for_each            = module.container_registry.application_repositories
  source              = "./modules/deployment"
  deployment_document = module.deployment_template.ssm_document_name
  docker_image        = each.value.url
  application_name    = each.key
  docker_run_flags    = var.applications_config[each.key].flags
  application_ports   = var.applications_config[each.key].ports
  application_env     = var.applications_config[each.key].env
  application_cmd     = var.applications_config[each.key].cmd
  application_network = var.applications_config[each.key].network
  application_volumes = var.applications_config[each.key].volumes
  application_configs = var.applications_config[each.key].configs
  target_type         = var.create_autoscaling ? "autoscaling_group_name" : "instance_id"
  target_ref          = var.create_autoscaling ? module.computing.autoscaling_group : module.computing.ec2_instance_id
}

module "automations" {
  source = "./modules/automations"
  name   = var.name
}

module "deployment_events" {
  for_each                    = module.container_registry.application_repositories
  source                      = "./modules/deployment-events"
  name                        = "${var.name}-${each.key}"
  deployment_association_id   = module.deployment[each.key].ssm_association_id
  deployment_run_document_arn = module.automations.association_start_document_arn
  repository_name             = each.value.name
}
