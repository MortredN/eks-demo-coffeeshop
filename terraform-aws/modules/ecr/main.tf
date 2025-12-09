# App repositories
data "aws_ecr_repository" "app_frontend_repo" {
  name = "mortredn/eks-demo-coffeeshop-frontend"
}
data "aws_ecr_repository" "app_customer_repo" {
  name = "mortredn/eks-demo-coffeeshop-customer"
}
data "aws_ecr_repository" "app_shopping_repo" {
  name = "mortredn/eks-demo-coffeeshop-shopping"
}


# Helper repositories
## cert-manager
data "aws_ecr_repository" "cert_manager_webhook" {
  name = "jetstack/cert-manager-webhook"
}
data "aws_ecr_repository" "cert_manager_cainjector" {
  name = "jetstack/cert-manager-cainjector"
}
data "aws_ecr_repository" "cert_manager_controller" {
  name = "jetstack/cert-manager-controller"
}

## AWS LBC
data "aws_ecr_repository" "aws_lbc" {
  name = "eks/aws-load-balancer-controller"
}

## Secrets Store CSI Driver
data "aws_ecr_repository" "sscsi_node_driver_registrar" {
  name = "sig-storage/csi-node-driver-registrar"
}
data "aws_ecr_repository" "sscsi_driver" {
  name = "csi-secrets-store/driver"
}
data "aws_ecr_repository" "sscsi_livenessprobe" {
  name = "sig-storage/livenessprobe"
}
data "aws_ecr_repository" "sscsi_aws_provider" {
  name = "aws-secrets-manager/secrets-store-csi-driver-provider-aws"
}

## Metrics Server
data "aws_ecr_repository" "metrics_server" {
  name = "metrics-server/metrics-server"
}

## Cluster Autoscaler
data "aws_ecr_repository" "cluster_autoscaler" {
  name = "autoscaling/cluster-autoscaler"
}
