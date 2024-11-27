output "ssm_document_arn" {
  value = aws_ssm_document.docker_deployment.arn
}

output "ssm_document_name" {
  value = aws_ssm_document.docker_deployment.name
}
