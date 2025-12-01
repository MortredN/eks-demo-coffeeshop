output "rds_db_customer_endpoint" {
  value = aws_db_instance.rds_db_customer.endpoint
}

output "rds_db_customer_secret_arn" {
  value = aws_db_instance.rds_db_customer.master_user_secret[0].secret_arn
}

output "rds_db_shopping_endpoint" {
  value = aws_db_instance.rds_db_shopping.endpoint
}

output "rds_db_shopping_secret_arn" {
  value = aws_db_instance.rds_db_shopping.master_user_secret[0].secret_arn
}
