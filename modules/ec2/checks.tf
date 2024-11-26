check "eip_validation" {
  assert {
    condition     = !(var.ec2_create_eip && var.create_autoscaling)
    error_message = "ec2_create_eip can't be set true with create_autoscaling = true"
  }
}

check "instance_max_count_validation" {
  assert {
    condition     = !(var.ec2_instance_count_max > 1 && !var.create_autoscaling)
    error_message = "ec2_instance_count_max can't be set > 1 with create_autoscaling = false"
  }
}

check "instance_min_count_validation" {
  assert {
    condition     = !(var.ec2_instance_count_min > 1 && !var.create_autoscaling)
    error_message = "ec2_instance_count_min can't be set > 1 with create_autoscaling = false"
  }
}
