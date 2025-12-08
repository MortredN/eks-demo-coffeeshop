# App repositories
resource "aws_ecr_repository" "app_frontend_repo" {
  name                 = "mortredn/eks-demo-coffeeshop-frontend"
  image_tag_mutability = "MUTABLE"
  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_ecr_repository" "app_customer_repo" {
  name                 = "mortredn/eks-demo-coffeeshop-customer"
  image_tag_mutability = "MUTABLE"
  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_ecr_repository" "app_shopping_repo" {
  name                 = "mortredn/eks-demo-coffeeshop-shopping"
  image_tag_mutability = "MUTABLE"
  lifecycle {
    prevent_destroy = true
  }
}


# Helper repositories
## cert-manager
resource "aws_ecr_repository" "cert_manager_webhook" {
  name                 = "jetstack/cert-manager-webhook"
  image_tag_mutability = "MUTABLE"
  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_ecr_repository" "cert_manager_cainjector" {
  name                 = "jetstack/cert-manager-cainjector"
  image_tag_mutability = "MUTABLE"
  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_ecr_repository" "cert_manager_controller" {
  name                 = "jetstack/cert-manager-controller"
  image_tag_mutability = "MUTABLE"
  lifecycle {
    prevent_destroy = true
  }
}

## AWS LBC
resource "aws_ecr_repository" "aws_lbc" {
  name                 = "eks/aws-load-balancer-controller"
  image_tag_mutability = "MUTABLE"
  lifecycle {
    prevent_destroy = true
  }
}

## Secrets Store CSI Driver
resource "aws_ecr_repository" "sscsi_node_driver_registrar" {
  name                 = "sig-storage/csi-node-driver-registrar"
  image_tag_mutability = "MUTABLE"
  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_ecr_repository" "sscsi_driver" {
  name                 = "csi-secrets-store/driver"
  image_tag_mutability = "MUTABLE"
  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_ecr_repository" "sscsi_livenessprobe" {
  name                 = "sig-storage/livenessprobe"
  image_tag_mutability = "MUTABLE"
  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_ecr_repository" "sscsi_aws_provider" {
  name                 = "aws-secrets-manager/secrets-store-csi-driver-provider-aws"
  image_tag_mutability = "MUTABLE"
  lifecycle {
    prevent_destroy = true
  }
}

## Metrics Server
resource "aws_ecr_repository" "metrics_server" {
  name                 = "kubernetes-sigs/metrics-server"
  image_tag_mutability = "MUTABLE"
  lifecycle {
    prevent_destroy = true
  }
}

## Cluster Autoscaler
resource "aws_ecr_repository" "cluster_autoscaler" {
  name                 = "autoscaling/cluster-autoscaler"
  image_tag_mutability = "MUTABLE"
  lifecycle {
    prevent_destroy = true
  }
}
