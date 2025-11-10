variable "region_primary" {
  description = "Primary AWS Region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "az1" {
  description = "AZ1 for subnets: EKS 1, RDS 1, ALB 1"
  type        = string
  default     = "us-east-1a"
}
variable "az2" {
  description = "AZ for subnets: EKS 2, RDS 2, ALB 2"
  type        = string
  default     = "us-east-1b"
}
variable "az3" {
  description = "AZ for subnets: SSM Bastion & NAT Gateway"
  type        = string
  default     = "us-east-1c"
}
