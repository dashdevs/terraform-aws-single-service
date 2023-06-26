output "lb_target_group_arns" {
  value = [
    for group in aws_lb_target_group.ec2 : group.arn
  ]
}

output "lb_listener_arn" {
  value = aws_lb_listener.ec2[0].arn
}
