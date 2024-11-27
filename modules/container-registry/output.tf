output "application_repositories" {
  value = {
    for application_name, repository in aws_ecr_repository.ecr : application_name => {
      name = repository.name
      url  = repository.repository_url
    }
  }
}
