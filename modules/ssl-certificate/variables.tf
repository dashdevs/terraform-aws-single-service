variable "domain_name" {
  type = string
}

variable "domain_zone_name" {
  type    = string
  default = null
}

variable "create_dns_records" {
  type    = bool
  default = false
}

variable "is_virginia_region" {
  type    = bool
  default = false
}
