output "repository_names" {
  value = [
    for ecr in aws_ecr_repository.ecr : ecr.name
  ]
}
