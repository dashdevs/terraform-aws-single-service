resource "aws_ecr_repository" "ecr" {
  for_each             = { for name in var.application_names : name => name }
  name                 = "${var.name}/${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
