variable "root-domain" {
  description = "A list of the registered base domains which will each get it's own hosted zone"
  type        = string
}

variable "subdomain-specs" {
  type = map(object({
    name             = string
    public-zone-tags = map(string)
  }))
}

variable "delegation-set-name" {
  description = "Name of delegation to use in hosted zones"
  type        = string
}

variable "record-mapping" {
  type = map(list(object({
    instance-ip = string
    record-name = string
  })))
}

variable "default-tags" {
  type    = map(string)
  default = {}
}