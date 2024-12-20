data "aws_default_tags" "current" {}

locals {
  instance_name_tag = "${var.name}-${var.ec2_instance_name_postfix}"
  ecr_based_deployment_policy = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
  managed_policy_arns = concat(var.iam_role_additional_policies, var.attach_ecr_based_deployment_policy ? local.ecr_based_deployment_policy : [])
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_iam_role" "ec2" {
  name = "${var.name}-${var.ec2_instance_name_postfix}-ec2-role"

  assume_role_policy = <<-EOF
{
   "Version": "2012-10-17",
   "Statement": [
     {
       "Action": "sts:AssumeRole",
       "Principal": {
         "Service": "ec2.amazonaws.com"
       },
       "Effect": "Allow",
       "Sid": ""
     }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2" {
  count      = length(local.managed_policy_arns)
  role       = aws_iam_role.ec2.name
  policy_arn = local.managed_policy_arns[count.index]
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name}-${var.ec2_instance_name_postfix}-ec2-profile"
  role = aws_iam_role.ec2.name
}

resource "aws_instance" "ec2" {
  count                       = var.create_autoscaling ? 0 : 1
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = var.ec2_create_eip
  iam_instance_profile        = aws_iam_instance_profile.ec2.id
  instance_type               = var.ec2_instance_type
  key_name                    = aws_key_pair.ec2.key_name
  subnet_id                   = var.ec2_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ec2.id]

  tags = {
    Name = local.instance_name_tag
  }

  root_block_device {
    volume_size = var.ec2_root_storage_size
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_launch_configuration" "core_conf" {
  count                = var.create_autoscaling ? 1 : 0
  name_prefix          = "${var.name}-lc"
  image_id             = data.aws_ami.amazon-linux-2.id
  iam_instance_profile = aws_iam_instance_profile.ec2.id
  instance_type        = var.ec2_instance_type
  key_name             = aws_key_pair.ec2.key_name
  security_groups      = [aws_security_group.ec2.id]

  root_block_device {
    volume_size = var.ec2_root_storage_size
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ec2" {
  count                = var.create_autoscaling ? 1 : 0
  name                 = "${var.name}-autoscaling-group"
  launch_configuration = aws_launch_configuration.core_conf[0].name
  min_size             = var.ec2_instance_count_min
  max_size             = var.ec2_instance_count_max
  vpc_zone_identifier  = var.ec2_subnets
  target_group_arns    = var.target_group_arns

  tag {
    key                 = "Name"
    value               = local.instance_name_tag
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = data.aws_default_tags.current.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "ec2" {
  count    = var.ec2_create_eip ? 1 : 0
  instance = aws_instance.ec2[0].id
}

resource "aws_security_group" "ec2" {
  name        = "${var.name}-${var.ec2_instance_name_postfix}-ec2"
  description = "Allow all necessary ports"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = toset(var.ec2_ingress_ports)
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = ["0.0.0.0/0"]
      protocol    = "tcp"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ssm_document" "ec2_config" {
  name            = "${var.name}-${var.ec2_instance_name_postfix}-ec2-config"
  document_format = "YAML"
  document_type   = "Command"
  target_type     = "/AWS::EC2::Instance"
  content         = file("${path.module}/config.yaml")
}

resource "aws_ssm_association" "ec2_config" {
  name = aws_ssm_document.ec2_config.name
  targets {
    key    = "tag:Name"
    values = [local.instance_name_tag]
  }
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "ec2" {
  key_name   = "${var.name}-${var.ec2_instance_name_postfix}-key"
  public_key = tls_private_key.key.public_key_openssh
}
