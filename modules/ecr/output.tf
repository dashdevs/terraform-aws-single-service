output "application_repository_names" {
  value = {
    for application_name, repository in aws_ecr_repository.ecr : application_name => repository.name
  }
}
