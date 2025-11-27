output "app_urls" {
  value = [
    aws_ecr_repository.app_frontend_repo.repository_url,
    aws_ecr_repository.app_customer_repo.repository_url,
    aws_ecr_repository.app_shopping_repo.repository_url,
  ]
}
