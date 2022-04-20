variable "region" {
  type        = string
  description = "AWS Region in which VPC will be created"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "AWS VPC tags "
}

variable "instance_tenancy" {
  type        = string
  description = "VPC Tenancy model"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR Block specified to VPC"
}