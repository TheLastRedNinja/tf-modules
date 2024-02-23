data "aws_route53_zone" "public-zone" {
  name         = "${var.dns_domain}.${var.root_domain}"
  private_zone = false
}

data "aws_route53_zone" "private-zone" {
  name         = "${var.dns_domain}.${var.root_domain}"
  private_zone = true
}

locals {
  public-record-it  = { for host, ips in var.hosts_in_public_zone : "${host}.${var.dns_domain}" => { host = host, ips = ips } }
  private-record-it = { for host, ips in var.hosts_in_private_zone : "${host}.${var.dns_domain}" => { host = host, ips = ips } }
}

//noinspection HILUnresolvedReference
resource "aws_route53_record" "public-records" {
  for_each = local.public-record-it

  name    = each.value.host
  type    = "A"
  zone_id = data.aws_route53_zone.public-zone.zone_id
  ttl     = "60"
  records = each.value.ips
}

//noinspection HILUnresolvedReference
resource "aws_route53_record" "private-records" {
  for_each = local.private-record-it

  name    = each.value.host
  type    = "A"
  zone_id = data.aws_route53_zone.private-zone.zone_id
  ttl     = "60"
  records = each.value.ips
}