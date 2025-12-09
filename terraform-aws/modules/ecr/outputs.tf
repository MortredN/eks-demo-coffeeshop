output "app_urls" {
  value = [
    data.aws_ecr_repository.app_frontend_repo.repository_url,
    data.aws_ecr_repository.app_customer_repo.repository_url,
    data.aws_ecr_repository.app_shopping_repo.repository_url,
  ]
}

output "helper_urls" {
  value = [
    data.aws_ecr_repository.cert_manager_webhook.repository_url,
    data.aws_ecr_repository.cert_manager_cainjector.repository_url,
    data.aws_ecr_repository.cert_manager_controller.repository_url,
    data.aws_ecr_repository.aws_lbc.repository_url,
    data.aws_ecr_repository.sscsi_node_driver_registrar.repository_url,
    data.aws_ecr_repository.sscsi_driver.repository_url,
    data.aws_ecr_repository.sscsi_livenessprobe.repository_url,
    data.aws_ecr_repository.sscsi_aws_provider.repository_url,
    data.aws_ecr_repository.metrics_server.repository_url,
    data.aws_ecr_repository.cluster_autoscaler.repository_url,
  ]
}
