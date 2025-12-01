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
      contains(keys(var.subnet_ids), "bastion")
    )
    error_message = "The subnet_ids must contain 'bastion'"
  }
}
