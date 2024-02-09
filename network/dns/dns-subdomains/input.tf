variable "root-domain" {
  description = "A list of the registered base domains which will each get it's own hosted zone"
  type        = string
}

variable "subdomain-specs" {
  type = map(object({
    domain-name        = string
    create-public-zone = bool
    public-zone-tags   = map(string)
    private-zone-tags  = map(string)
    comment            = string
  }))
}

variable "delegation-set-name" {
  description = "Name of delegation to use in hosted zones"
  type        = string
  default     = ""
}

variable "default-tags" {
  type    = map(string)
  default = {}
}

variable "vpc-id" {
  type = string
}