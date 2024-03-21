locals {
  application_names = [
    for config in var.applications_config : config.application_name
  ]
  ssm_document_name = "${var.name}-${var.applications_config[count.index].application_name}-ssm-delivery-script"
}

module "ecr" {
  source            = "./modules/ecr"
  name              = var.name
  application_names = local.application_names
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
  ssm_document_name                  = local.ssm_document_name
}

module "deployment" {
  count                     = length(module.ecr.repository_names)
  source                    = "./modules/ssm-document"
  name                      = var.name
  autoscaling_group         = module.ec2.autoscaling_group
  instance_name             = module.ec2.ec2_instance_name
  repository_name           = module.ecr.repository_names[count.index]
  application_name          = var.applications_config[count.index].application_name
  application_ports         = var.applications_config[count.index].application_ports
  application_start_command = var.applications_config[count.index].application_start_command
  application_env_vars      = var.applications_config[count.index].application_env_vars
  ssm_document_name         = local.ssm_document_name
}
