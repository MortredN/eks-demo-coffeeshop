# Referencing from root
variable "project_name" {}
variable "az1" {}
variable "az2" {}
variable "az3" {}

variable "main_vpc_cidr" {
  description = "Main VPC's CIDR Range"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_eks1_cidr" {
  description = "Subnet EKS 1's CIDR Range (private)"
  type        = string
  default     = "10.0.1.0/24"
}
variable "subnet_eks2_cidr" {
  description = "Subnet EKS 2's CIDR Range (private)"
  type        = string
  default     = "10.0.2.0/24"
}
variable "subnet_rds1_cidr" {
  description = "Subnet RDS 1's CIDR Range (private)"
  type        = string
  default     = "10.0.3.0/24"
}
variable "subnet_rds2_cidr" {
  description = "Subnet RDS 2's CIDR Range (private)"
  type        = string
  default     = "10.0.4.0/24"
}
variable "subnet_alb1_cidr" {
  description = "Subnet ALB 1's CIDR Range (public)"
  type        = string
  default     = "10.0.5.0/24"
}
variable "subnet_alb2_cidr" {
  description = "Subnet ALB 2's CIDR Range (public)"
  type        = string
  default     = "10.0.6.0/24"
}
variable "subnet_ssm_cidr" {
  description = "Subnet SSM (Bastion)'s CIDR Range (private)"
  type        = string
  default     = "10.0.7.0/24"
}
variable "subnet_natgw_cidr" {
  description = "Subnet NAT Gateway's CIDR Range (public)"
  type        = string
  default     = "10.0.8.0/24"
}
