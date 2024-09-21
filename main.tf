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

module "deployments" {
  for_each          = module.ecr.application_repository_names
  source            = "./modules/deployment"
  name              = var.name
  image_name        = each.value
  application_name  = each.key
  application_ports = var.applications_config[each.key].ports
  application_env   = var.applications_config[each.key].env
  application_cmd   = var.applications_config[each.key].cmd
}

module "deployment_triggers" {
  for_each            = module.ecr.application_repository_names
  source              = "./modules/ssm-document"
  name                = "${var.name}-${each.key}"
  autoscaling_group   = module.ec2.autoscaling_group
  instance_name       = module.ec2.ec2_instance_name
  repository_name     = each.value
  deployment_document = module.deployments[each.key].ssm_document_arn
}
