# Getting Account ID
data "aws_caller_identity" "current" {}

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
  enable_cloudfront    = var.enable_cloudfront
  enable_cloudwatch    = var.enable_cloudwatch
}

module "rds" {
  source            = "./modules/rds"
  project_name      = local.project_name
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.subnet_ids
  eks_cluster_sg_id = module.eks.eks_cluster_sg_id
  bastion_rds_sg_id = module.bastion.bastion_rds_sg_id
}

module "secret" {
  source                     = "./modules/secret"
  project_name               = local.project_name
  oidc_eks_cluster_arn       = module.eks.oidc_eks_cluster_arn
  oidc_eks_cluster_url       = module.eks.oidc_eks_cluster_url
  rds_db_customer_secret_arn = module.rds.rds_db_customer_secret_arn
  rds_db_shopping_secret_arn = module.rds.rds_db_shopping_secret_arn
}

module "codepipeline" {
  source            = "./modules/codepipeline"
  project_name      = local.project_name
  region_primary    = var.region_primary
  aws_account_id    = data.aws_caller_identity.current.account_id
  eks_cluster_name  = module.eks.eks_cluster_name
  ecr_app_urls      = module.ecr.app_urls
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.subnet_ids
  subnet_arns       = module.vpc.subnet_arns
  bastion_eks_sg_id = module.bastion.bastion_eks_sg_id
}
