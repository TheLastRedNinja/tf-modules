locals {
  public-zone-iterator = {
    for k, v in var.subdomain-specs :
    k => v if v.create-public-zone
  }
}

################################################################
## Public Zone Resources
################################################################

resource "aws_route53_delegation_set" "this" {
  count = var.delegation-set-name != "" ? 1 : 0

  reference_name = var.delegation-set-name
}

//noinspection HILUnresolvedReference
resource "aws_route53_zone" "public-zone" {
  for_each = local.public-zone-iterator

  name    = "${each.value.domain-name}.${var.root-domain}"
  comment = each.value.comment

  delegation_set_id = try(aws_route53_delegation_set.this.0.id, null)

  tags = merge(var.default-tags, each.value.public-zone-tags, {
    Name = each.value.domain-name
  })
}

data "aws_route53_zone" "parent-public-zone" {
  name         = var.root-domain
  private_zone = false
}

resource "aws_route53_record" "parent-public-ns" {
  for_each = aws_route53_zone.public-zone

  name    = each.key
  type    = "NS"
  zone_id = data.aws_route53_zone.parent-public-zone.zone_id
  ttl     = "60"
  records = each.value.name_servers
}

################################################################
## Private Zone Resources
################################################################

#TODO: Find better way to deal with this. If the module is used twice with the same root domain a duplicate private parent zone is created
//noinspection HILUnresolvedReference
resource "aws_route53_zone" "private-zone" {
  for_each = var.subdomain-specs

  name    = "${each.value.domain-name}.${var.root-domain}"
  comment = each.value.comment

  vpc {
    vpc_id = var.vpc-id
  }

  tags = merge(var.default-tags, each.value.private-zone-tags, {
    Name = each.value.domain-name
  })
}

resource "aws_route53_zone" "parent-private-zone" {
  name    = var.root-domain
  comment = "The parent hosted zone to be used for future demos"

  vpc {
    vpc_id = var.vpc-id
  }

  tags = merge(var.default-tags, {
    Name = var.root-domain
  })
}

resource "aws_route53_record" "parent-private-ns" {
  for_each = aws_route53_zone.private-zone

  name    = each.key
  type    = "NS"
  zone_id = aws_route53_zone.parent-private-zone.zone_id
  ttl     = "60"
  records = each.value.name_servers
}