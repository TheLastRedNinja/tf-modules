resource "aws_route53_delegation_set" "this" {
  reference_name = var.delegation-set-name
}

//noinspection HILUnresolvedReference
resource "aws_route53_zone" "public-zone" {
  for_each = var.subdomain-specs

  name              = "${each.value.name}.${var.root-domain}"
  delegation_set_id = aws_route53_delegation_set.this.id

  tags = merge(var.default-tags, each.value.public-zone-tags, {
    Name = each.value.name
  })
}

data "aws_route53_zone" "parent-public-zone" {
  name         = var.root-domain
  private_zone = false
}

resource "aws_route53_record" "parent-ns" {
  for_each = aws_route53_zone.public-zone

  name    = each.key
  type    = "NS"
  zone_id = data.aws_route53_zone.parent-public-zone.zone_id
  ttl     = "60"
  records = each.value.name_servers
}

locals {
  record-it = flatten([
    for zone, spec in aws_route53_zone.public-zone :
      [for item in var.record-mapping[zone] : {
        zone-name   = spec.tags["Name"]
        zone-id     = spec.zone_id
        instance-ip = item.instance-ip
        record-name = item.record-name
      }
    ]
  ])
}

//noinspection HILUnresolvedReference
resource "aws_route53_record" "public-record" {
  for_each = { for k,v in local.record-it: "${v.record-name}.${v.zone-name}" => v}

  name    = each.value.record-name
  type    = "A"
  zone_id = each.value.zone-id
  ttl     = "60"
  records = [each.value.instance-ip]
}