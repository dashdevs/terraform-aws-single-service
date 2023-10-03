output "ec2_ssh_keypair_value" {
  value = tls_private_key.key.private_key_pem
}

output "ec2_keypair_name" {
  value = aws_key_pair.ec2.key_name
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2.id
}

output "ec2_instance_role" {
  value = aws_iam_role.ec2.id
}

output "ec2_instance_id" {
  value = var.create_autoscaling ? null : aws_instance.ec2[0].id
}

output "autoscaling_group" {
  value = var.create_autoscaling ? aws_autoscaling_group.ec2[0].name : null
}

output "ec2_instance_name" {
  value = local.instance_name_tag
}

output "ec2_elastic_ip_address" {
  value = var.ec2_create_eip ? aws_eip.ec2[0].public_ip : null
}
