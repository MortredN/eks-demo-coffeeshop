# Referencing from root
variable "project_name" {
  type = string
}
variable "region_primary" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  type = map(string)
  validation {
    condition = (
      contains(keys(var.subnet_ids), "eks1") &&
      contains(keys(var.subnet_ids), "eks2")
    )
    error_message = "The subnet_ids must contain 'eks1', 'eks2'"
  }
}
variable "route_table_ids" {
  type = map(string)
  validation {
    condition = (
      contains(keys(var.route_table_ids), "private")
    )
    error_message = "The route_table_ids must contain 'private'"
  }
}
variable "bastion_eks_role_arn" {
  type = string
}
variable "bastion_eks_sg_id" {
  type = string
}

# Used only when the ALB has been created by the AWS LBC
variable "enable_cloudfront" {
  description = "Enable CloudFront distribution (set to true after ALB is created)"
  type        = bool
  default     = false
}
variable "alb_name" {
  description = "The ALB's name (based on the ingress manifest)"
  type        = string
  default     = "eks-demo-alb"
}
variable "alb_namespace" {
  description = "Namespace where the ALB is deployed"
  type        = string
  default     = "default"
}
