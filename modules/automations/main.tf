resource "aws_ssm_document" "association_start" {
  name            = "${var.name}-association-start"
  document_format = "YAML"
  document_type   = "Automation"
  content         = file("${path.module}/documents/association-start.yaml")
}
