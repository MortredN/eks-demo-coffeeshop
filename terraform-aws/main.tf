module "ecr" {
  source = "./modules/ecr"
}

module "vpc" {
  source       = "./modules/vpc"
  project_name = local.project_name
  az1          = var.az1
  az2          = var.az2
  az3          = var.az3
}
