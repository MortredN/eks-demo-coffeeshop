output "ecr_app_urls" {
  value = module.ecr.app_urls
}

output "bastion_eks_instance_id" {
  value = module.bastion.bastion_eks_instance_id
}