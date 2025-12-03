output "eks_cluster_sg_id" {
  value = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "aws_lbc_role_arn" {
  value = aws_iam_role.aws_lbc_role.arn
}

output "acm_cert_validation_record" {
  value = {
    name  = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
    value = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value
    type  = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
  }
}

output "acm_cert_arn" {
  value = aws_acm_certificate.cert.arn
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.main[0].domain_name
}
