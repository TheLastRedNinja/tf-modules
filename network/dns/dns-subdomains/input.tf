variable "root_domain" {
  description = "A list of the registered base domains which will each get it's own hosted zone"
  type        = string
}

variable "subdomain_specs" {
  type = map(object({
    domain-name        = string
    create-public-zone = bool
    public-zone-tags   = map(string)
    private-zone-tags  = map(string)
    comment            = string
  }))
}

variable "delegation_set_name" {
  description = "Name of delegation to use in hosted zones"
  type        = string
  default     = ""
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
  type = string
}