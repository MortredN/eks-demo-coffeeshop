output "bastion_eks_instance_id" {
  value = aws_instance.bastion_eks.id
}

output "bastion_eks_role_arn" {
  value = aws_iam_role.bastion_eks_role.arn
}

output "bastion_eks_sg_id" {
  value = aws_security_group.bastion_eks_sg.id
}
