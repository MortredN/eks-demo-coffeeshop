# App repositories
resource "aws_ecr_repository" "app_frontend" {
  name                 = "mortredn/eks-demo-coffeeshop-frontend"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "app_customer" {
  name                 = "mortredn/eks-demo-coffeeshop-customer"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "app_shopping" {
  name                 = "mortredn/eks-demo-coffeeshop-shopping"
  image_tag_mutability = "MUTABLE"
}
