output "app_urls" {
  value = [
    aws_ecr_repository.app_frontend.repository_url,
    aws_ecr_repository.app_customer.repository_url,
    aws_ecr_repository.app_shopping.repository_url,
  ]
}
