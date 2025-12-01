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

module "bastion" {
  source       = "./modules/bastion"
  project_name = local.project_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.subnet_ids
}

module "eks" {
  source               = "./modules/eks"
  project_name         = local.project_name
  region_primary       = var.region_primary
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.subnet_ids
  route_table_ids      = module.vpc.route_table_ids
  bastion_eks_role_arn = module.bastion.bastion_eks_role_arn
  bastion_eks_sg_id    = module.bastion.bastion_eks_sg_id
}

