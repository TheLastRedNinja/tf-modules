data "aws_route53_zone" "public-zone" {
  name         = "${var.dns-domain}.${var.root-domain}"
  private_zone = false
}

data "aws_route53_zone" "private-zone" {
  name         = "${var.dns-domain}.${var.root-domain}"
  private_zone = true
}

locals {
  public-record-it  = { for host, ips in var.hosts-in-public-zone : "${host}.${var.dns-domain}" => { host = host, ips = ips } }
  private-record-it = { for host, ips in var.hosts-in-private-zone : "${host}.${var.dns-domain}" => { host = host, ips = ips } }
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