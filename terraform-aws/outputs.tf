output "ecr_app_urls" {
  value = module.ecr.app_urls
}

output "bastion_eks_instance_id" {
  value = module.bastion.bastion_eks_instance_id
}

output "bastion_rds_instance_id" {
  value = module.bastion.bastion_rds_instance_id
}

output "rds_db_customer_endpoint" {
  value = module.rds.rds_db_customer_endpoint
}

output "rds_db_customer_secret_arn" {
  value = module.rds.rds_db_customer_secret_arn
}

output "rds_db_shopping_endpoint" {
  value = module.rds.rds_db_shopping_endpoint
}

output "rds_db_shopping_secret_arn" {
  value = module.rds.rds_db_shopping_secret_arn
}
