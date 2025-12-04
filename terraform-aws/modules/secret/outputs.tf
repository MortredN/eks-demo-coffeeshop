output "token_secret_arn" {
  value = aws_secretsmanager_secret.token_secret.arn
}

output "sscsi_customer_role_arn" {
  value = aws_iam_role.sscsi_customer_role.arn
}

output "sscsi_shopping_role_arn" {
  value = aws_iam_role.sscsi_shopping_role.arn
}
