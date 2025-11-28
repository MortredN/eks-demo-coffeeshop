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

module "eks" {
  source          = "./modules/eks"
  project_name    = local.project_name
  region_primary  = var.region_primary
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.subnet_ids
  route_table_ids = module.vpc.route_table_ids
}

module "bastion" {
  source       = "./modules/bastion"
  project_name = local.project_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.subnet_ids
}

