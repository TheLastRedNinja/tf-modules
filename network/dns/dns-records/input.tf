variable "root_domain" {
  type = string
}

variable "dns_domain" {
  type = string
}

variable "hosts_in_private_zone" {
  type    = map(any)
  default = {}
}

variable "hosts_in_public_zone" {
  type    = map(any)
  default = {}
}