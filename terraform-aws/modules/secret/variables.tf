# Referencing from root
variable "project_name" {
  type = string
}
variable "oidc_eks_cluster_arn" {
  type = string
}
variable "oidc_eks_cluster_url" {
  type = string
}
variable "rds_db_customer_secret_arn" {
  type = string
}
variable "rds_db_shopping_secret_arn" {
  type = string
}
