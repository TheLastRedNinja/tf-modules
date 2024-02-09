variable "root-domain" {
  type = string
}

variable "dns-domain" {
  type = string
}

variable "hosts-in-private-zone" {
  type    = map(any)
  default = {}
}

variable "hosts-in-public-zone" {
  type    = map(any)
  default = {}
}