# Referencing from root
variable "project_name" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  type = map(string)
  validation {
    condition = (
      contains(keys(var.subnet_ids), "rds1") &&
      contains(keys(var.subnet_ids), "rds2")
    )
    error_message = "The subnet_ids must contain 'rds1', 'rds2'"
  }
}
variable "eks_cluster_sg_id" {
  type = string
}
variable "bastion_rds_sg_id" {
  type = string
}
