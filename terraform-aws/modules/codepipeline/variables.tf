# Referencing from root
variable "project_name" {
  type = string
}
variable "region_primary" {
  type = string
}
variable "aws_account_id" {
  type = string
}
variable "eks_cluster_name" {
  type = string
}
variable "ecr_app_urls" {
  type = map(string)
  validation {
    condition = (
      contains(keys(var.ecr_app_urls), "frontend")
    )
    error_message = "The ecr_app_urls must contain 'frontend'"
  }
}
variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  type = map(string)
  validation {
    condition = (
      contains(keys(var.subnet_ids), "bastion")
    )
    error_message = "The subnet_ids must contain 'bastion'"
  }
}
variable "subnet_arns" {
  type = map(string)
  validation {
    condition = (
      contains(keys(var.subnet_arns), "bastion")
    )
    error_message = "The subnet_arns must contain 'bastion'"
  }
}
variable "bastion_eks_sg_id" {
  type = string
}

variable "codeconnection_github_name" {
  type    = string
  default = "mortredn-aws-github"
}
