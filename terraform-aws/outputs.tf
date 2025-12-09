output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "ecr_app_urls" {
  value = module.ecr.app_urls
}

output "ecr_helper_urls" {
  value = module.ecr.helper_urls
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

output "aws_lbc_role_arn" {
  value = module.eks.aws_lbc_role_arn
}

output "acm_cert_validation_record" {
  value = module.eks.acm_cert_validation_record
}

output "acm_cert_arn" {
  value = module.eks.acm_cert_arn
}

output "cloudfront_domain_name" {
  value = module.eks.cloudfront_domain_name
}

output "token_secret_arn" {
  value = module.secret.token_secret_arn
}

output "sscsi_customer_role_arn" {
  value = module.secret.sscsi_customer_role_arn
}

output "sscsi_shopping_role_arn" {
  value = module.secret.sscsi_shopping_role_arn
}

output "cluster_autoscaler_role_arn" {
  value = module.eks.cluster_autoscaler_role_arn
}

output "cloudwatch_agent_role_arn" {
  value = module.eks.cloudwatch_agent_role_arn
}
