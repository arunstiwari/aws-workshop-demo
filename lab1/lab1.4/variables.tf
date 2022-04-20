variable "vpc_cidr_block" {
  type = string
  description = "CIDR block for VPC network"
}

variable "additional_tags" {
  type = string
  description = "Tags for VPC network"
}
variable "instance_tenancy" {
  type = string
  description = "Tenancy for VPC network"
}

variable "name_prefix" {
  type = string
  description = "Name prefix for VPC network"
}
variable "enable_ipv6" {
  type = bool
  description = "Enabling IPV6 for VPC network"
}
variable "enable_dns_hostnames" {
  type = bool
  description = "Enabling DNS Hostnames for VPC network"
}
variable "enable_dns_support" {
  type = bool
  description = "Enabling DNS support for VPC network"
}

variable "availability_zones" {
  type = list(string)
  description = "Availability zones for VPC region"
}

variable "public_subnets_cidr_per_az" {
  type = list(string)
  description = "CIDR block for Public Subnets"
}

variable "single_nat" {
 type = bool
  description = "True means single nat instance"
}

variable "pvt_subnet_cidrs_per_az" {
  type = list(string)
  description = "CIDR block for Private Subnets"
}