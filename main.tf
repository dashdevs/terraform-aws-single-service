module "ecr" {
  source            = "./modules/ecr"
  name              = var.name
  application_names = keys(var.applications_config)
}

module "ec2" {
  source                             = "./modules/ec2"
  name                               = var.name
  vpc_id                             = var.vpc_id
  ec2_subnets                        = var.ec2_subnets
  ec2_create_eip                     = var.ec2_create_eip
  ec2_instance_type                  = var.ec2_instance_type
  create_autoscaling                 = var.create_autoscaling
  ec2_instance_count_min             = var.ec2_instance_count_min
  ec2_instance_count_max             = var.ec2_instance_count_max
  attach_ecr_based_deployment_policy = var.attach_ecr_based_deployment_policy
  iam_role_additional_policies       = var.iam_role_additional_policies
  target_group_arns                  = var.target_group_arns
  ec2_instance_name_postfix          = var.ec2_instance_name_postfix
  ec2_ingress_ports                  = var.ec2_ingress_ports
}

module "deployment_template" {
  source = "./modules/deployment-template"
  name   = var.name
}

module "deployment" {
  for_each            = module.ecr.application_repositories
  source              = "./modules/deployment"
  deployment_document = module.deployment_template.ssm_document_name
  docker_image        = each.value.url
  application_name    = each.key
  application_ports   = var.applications_config[each.key].ports
  application_env     = var.applications_config[each.key].env
  application_cmd     = var.applications_config[each.key].cmd
  target_type         = var.create_autoscaling ? "autoscaling_group_name" : "instance_id"
  target_ref          = var.create_autoscaling ? module.ec2.autoscaling_group : module.ec2.ec2_instance_id
}

module "automations" {
  source = "./modules/automations"
  name   = var.name
}

module "deployment_events" {
  for_each                    = module.ecr.application_repositories
  source                      = "./modules/deployment-events"
  name                        = "${var.name}-${each.key}"
  deployment_association_id   = module.deployment[each.key].ssm_association_id
  deployment_run_document_arn = module.automations.association_start_document_arn
  repository_name             = each.value.name
}
