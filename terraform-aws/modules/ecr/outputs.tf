output "app_urls" {
  value = {
    frontend = data.aws_ecr_repository.app_frontend_repo.repository_url
    customer = data.aws_ecr_repository.app_customer_repo.repository_url
    shopping = data.aws_ecr_repository.app_shopping_repo.repository_url
  }
}

output "helper_urls" {
  value = {
    cert_manager_webhook        = data.aws_ecr_repository.cert_manager_webhook.repository_url
    cert_manager_cainjector     = data.aws_ecr_repository.cert_manager_cainjector.repository_url
    cert_manager_controller     = data.aws_ecr_repository.cert_manager_controller.repository_url
    aws_lbc                     = data.aws_ecr_repository.aws_lbc.repository_url
    sscsi_node_driver_registrar = data.aws_ecr_repository.sscsi_node_driver_registrar.repository_url
    sscsi_driver                = data.aws_ecr_repository.sscsi_driver.repository_url
    sscsi_livenessprobe         = data.aws_ecr_repository.sscsi_livenessprobe.repository_url
    sscsi_aws_provider          = data.aws_ecr_repository.sscsi_aws_provider.repository_url
    metrics_server              = data.aws_ecr_repository.metrics_server.repository_url
    cluster_autoscaler          = data.aws_ecr_repository.cluster_autoscaler.repository_url
    istio_proxyv2               = data.aws_ecr_repository.istio_proxyv2.repository_url
    istio_pilot                 = data.aws_ecr_repository.istio_pilot.repository_url
    prometheus                  = data.aws_ecr_repository.prometheus.repository_url
    prometheus_config_reloader  = data.aws_ecr_repository.prometheus_config_reloader.repository_url
    grafana                     = data.aws_ecr_repository.grafana.repository_url
    kiali                       = data.aws_ecr_repository.kiali.repository_url
  }
}
