resource "aws_lb" "ec2" {
  name               = "${var.name}-ec2-lb"
  internal           = var.is_lb_internal
  load_balancer_type = "network"
  subnets            = var.lb_subnets
}

resource "aws_lb_listener" "ec2" {
  count             = length(var.lb_listener_ports)
  load_balancer_arn = aws_lb.ec2.arn
  port              = var.lb_listener_ports[count.index]
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2[count.index].arn
  }
}

resource "aws_lb_target_group" "ec2" {
  count    = length(var.lb_target_ports)
  name     = "${var.name}-tg-${var.lb_target_ports[count.index]}"
  port     = var.lb_target_ports[count.index]
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    port     = "traffic-port"
    protocol = "HTTP"
    path     = var.target_health_check_path
  }
}

resource "aws_lb_target_group_attachment" "ec2" {
  count            = var.ec2_instance_id == null ? 0 : length(var.lb_target_ports)
  target_group_arn = aws_lb_target_group.ec2[count.index].arn
  target_id        = var.ec2_instance_id
  port             = var.lb_target_ports[count.index]
}
