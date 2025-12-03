# App repositories
resource "aws_ecr_repository" "app_frontend_repo" {
  name                 = "mortredn/eks-demo-coffeeshop-frontend"
  image_tag_mutability = "MUTABLE"
}
resource "aws_ecr_repository" "app_customer_repo" {
  name                 = "mortredn/eks-demo-coffeeshop-customer"
  image_tag_mutability = "MUTABLE"
}
resource "aws_ecr_repository" "app_shopping_repo" {
  name                 = "mortredn/eks-demo-coffeeshop-shopping"
  image_tag_mutability = "MUTABLE"
}


# Helper repositories
## cert-manager
resource "aws_ecr_repository" "cert_manager_webhook" {
  name                 = "jetstack/cert-manager-webhook"
  image_tag_mutability = "MUTABLE"
}
resource "aws_ecr_repository" "cert_manager_cainjector" {
  name                 = "jetstack/cert-manager-cainjector"
  image_tag_mutability = "MUTABLE"
}
resource "aws_ecr_repository" "cert_manager_controller" {
  name                 = "mortredn/eks-demo-coffeeshop-shopping"
  image_tag_mutability = "MUTABLE"
}

## AWS LBC
resource "aws_ecr_repository" "aws_lbc" {
  name                 = "eks/aws-load-balancer-controller"
  image_tag_mutability = "MUTABLE"
}
