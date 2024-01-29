#=======================================================================================================================
# VPC endpoints and security groups
#=======================================================================================================================

#required for eks:
#    com.amazonaws.<region>.ec2
#    com.amazonaws.<region>.ecr.api
#    com.amazonaws.<region>.ecr.dkr
#    com.amazonaws.<region>.s3 – For pulling container images
#    com.amazonaws.<region>.logs – For CloudWatch Logs
#    com.amazonaws.<region>.sts – If using AWS Fargate or IAM roles for service accounts
#    com.amazonaws.<region>.elasticloadbalancing – If using Application Load Balancers
#    com.amazonaws.<region>.autoscaling – If using Cluster Autoscaler
#    com.amazonaws.<region>.appmesh-envoy-management – If using App Mesh

# -----------------------------------------------------------
# lookup of subnets
# -----------------------------------------------------------

data "aws_vpc" "vpc" {
  id = var.vpc-id
}


# -----------------------------------------------------------
# S3 Endpoint
# -----------------------------------------------------------

resource "aws_vpc_endpoint" "s3" {
  count             = lookup(coalesce(var.create-endpoints, {}), "s3", false) ? 1 : 0
  vpc_id            = var.vpc-id
  service_name      = "com.amazonaws.${var.aws-region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = flatten(var.client-subnet-route-table-ids)

  tags = merge(var.tags, {
    "Name" = join("-", compact([var.aws-resource-name-prefix, "s3"]))
  })
}

# -----------------------------------------------------------
# SSM Endpoint
# -----------------------------------------------------------

resource "aws_security_group" "ssm_endpoint" {
  count = lookup(coalesce(var.create-endpoints, {}), "ssm", false) ? 1 : 0

  name        = join("-", compact([var.aws-resource-name-prefix, "ssm_endpoint"]))
  description = join("-", compact([var.aws-resource-name-prefix, "ssm_endpoint"]))
  vpc_id      = var.vpc-id
  tags = merge(var.tags, {
    "Name" = join("-", compact([var.aws-resource-name-prefix, "ssm_endpoint"]))
  })

  ingress {
    protocol    = "tcp"
    from_port   = "0"
    to_port     = "65535"
    description = "Traffic from AWS"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }
  egress {
    protocol    = "tcp"
    from_port   = "0"
    to_port     = "65535"
    description = "Traffic to AWS"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }
}

resource "aws_vpc_endpoint" "ssm" {
  count = lookup(coalesce(var.create-endpoints, {}), "ssm", false) ? 1 : 0

  vpc_id            = var.vpc-id
  service_name      = "com.amazonaws.${var.aws-region}.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = aws_security_group.ssm_endpoint.*.id

  subnet_ids          = flatten(var.placement-subnet-ids)
  private_dns_enabled = true

  tags = merge(var.tags, {
    "Name" = join("-", compact([var.aws-resource-name-prefix, "ssm"]))
  })
}

# -----------------------------------------------------------
# SSM Messages Endpoint
# -----------------------------------------------------------

resource "aws_security_group" "ssm_messages_endpoint" {
  count = lookup(coalesce(var.create-endpoints, {}), "ssm_messages", false) ? 1 : 0

  name        = join("-", compact([var.aws-resource-name-prefix, "ssm_messages_endpoint"]))
  description = join("-", compact([var.aws-resource-name-prefix, "ssm_messages_endpoint"]))
  vpc_id      = var.vpc-id

  tags = merge(var.tags, {
    "Name" = join("-", compact([var.aws-resource-name-prefix, "ssm_messages"]))
  })

  ingress {
    protocol    = "tcp"
    from_port   = "0"
    to_port     = "65535"
    description = "Traffic to AWS"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }
  egress {
    protocol    = "tcp"
    from_port   = "0"
    to_port     = "65535"
    description = "Traffic to AWS"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }
}

resource "aws_vpc_endpoint" "SSM_Messages_Endpoint" {
  count = lookup(coalesce(var.create-endpoints, {}), "ssm_messages", false) ? 1 : 0

  vpc_id            = var.vpc-id
  service_name      = "com.amazonaws.${var.aws-region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = aws_security_group.ssm_messages_endpoint.*.id

  subnet_ids          = flatten(var.placement-subnet-ids)
  private_dns_enabled = true

  tags = merge(var.tags, {
    "Name" = join("-", compact([var.aws-resource-name-prefix, "ssm_messages"]))
  })
}

# -----------------------------------------------------------
# EC2 Messages Endpoint
# -----------------------------------------------------------

resource "aws_security_group" "ec2_messages_endpoint" {
  count = lookup(coalesce(var.create-endpoints, {}), "ec2_messages", false) ? 1 : 0

  name        = join("-", compact([var.aws-resource-name-prefix, "ec2_messages"]))
  description = join("-", compact([var.aws-resource-name-prefix, "ec2_messages"]))
  vpc_id      = var.vpc-id
  tags = merge(var.tags, {
    "Name" = join("-", compact([var.aws-resource-name-prefix, "ec2_messages"]))
  })

  ingress {
    protocol    = "tcp"
    from_port   = "0"
    to_port     = "65535"
    description = "Traffic to AWS"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }
  egress {
    protocol    = "tcp"
    from_port   = "0"
    to_port     = "65535"
    description = "Traffic to AWS"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }
}

resource "aws_vpc_endpoint" "ec2_messages" {
  count = lookup(coalesce(var.create-endpoints, {}), "ec2_messages", false) ? 1 : 0

  vpc_id            = var.vpc-id
  service_name      = "com.amazonaws.${var.aws-region}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = aws_security_group.ec2_messages_endpoint.*.id

  subnet_ids          = flatten(var.placement-subnet-ids)
  private_dns_enabled = true

  tags = merge(var.tags, {
    "Name" = join("-", compact([var.aws-resource-name-prefix, "ec2_messages"]))
  })
}

# -----------------------------------------------------------
# AWS cloudwatch logs Endpoint
# -----------------------------------------------------------

resource "aws_security_group" "cloudwatch_logs_endpoint" {
  count = lookup(coalesce(var.create-endpoints, {}), "cloudwatch_logs", false) ? 1 : 0

  name        = join("-", compact([var.aws-resource-name-prefix, "cloudwatch_logs"]))
  description = join("-", compact([var.aws-resource-name-prefix, "cloudwatch_logs"]))
  vpc_id      = var.vpc-id
  tags = merge(var.tags, {
    "Name" = join("-", compact([var.aws-resource-name-prefix, "cloudwatch_logs"]))
  })

  ingress {
    protocol    = "tcp"
    from_port   = "0"
    to_port     = "65535"
    description = "Traffic to AWS"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }
  egress {
    protocol    = "tcp"
    from_port   = "0"
    to_port     = "65535"
    description = "Traffic from AWS"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  count = lookup(coalesce(var.create-endpoints, {}), "cloudwatch_logs", false) ? 1 : 0

  vpc_id            = var.vpc-id
  service_name      = "com.amazonaws.${var.aws-region}.logs"
  vpc_endpoint_type = "Interface"

  security_group_ids = aws_security_group.cloudwatch_logs_endpoint.*.id

  subnet_ids          = flatten(var.placement-subnet-ids)
  private_dns_enabled = true

  tags = merge(var.tags, {
    "Name" = join("-", compact([var.aws-resource-name-prefix, "cloudwatch_logs"]))
  })
}


# -----------------------------------------------------------
# AWS SecretsManager Endpoint
# -----------------------------------------------------------

resource "aws_security_group" "secrets_manager_endpoint" {
  count = lookup(coalesce(var.create-endpoints, {}), "secrets_manager", false) ? 1 : 0

  name        = join("-", compact([var.aws-resource-name-prefix, "secrets_manager"]))
  description = join("-", compact([var.aws-resource-name-prefix, "secrets_manager"]))
  vpc_id      = var.vpc-id
  tags = merge(var.tags, {
    "Name" = join("-", compact([var.aws-resource-name-prefix, "secrets_manager"]))
  })

  ingress {
    protocol    = "tcp"
    from_port   = "0"
    to_port     = "65535"
    description = "Traffic to AWS"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }
  egress {
    protocol    = "tcp"
    from_port   = "0"
    to_port     = "65535"
    description = "Traffic from AWS"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }
}

resource "aws_vpc_endpoint" "secrets_manager" {
  count = lookup(coalesce(var.create-endpoints, {}), "secrets_manager", false) ? 1 : 0

  vpc_id            = var.vpc-id
  service_name      = "com.amazonaws.${var.aws-region}.secretsmanager"
  vpc_endpoint_type = "Interface"

  security_group_ids = aws_security_group.secrets_manager_endpoint.*.id

  subnet_ids          = flatten(var.placement-subnet-ids)
  private_dns_enabled = true

  tags = merge(var.tags, {
    "Name" = join("-", compact([var.aws-resource-name-prefix, "secrets_manager"]))
  })
}


# -----------------------------------------------------------
# AWS Elasticache Endpoint
# -----------------------------------------------------------

resource "aws_security_group" "elasticache_endpoint" {
  count = lookup(coalesce(var.create-endpoints, {}), "elasticache", false) ? 1 : 0

  name        = join("-", compact([var.aws-resource-name-prefix, "elasticache"]))
  description = join("-", compact([var.aws-resource-name-prefix, "elasticache"]))
  vpc_id      = var.vpc-id
  tags = merge(var.tags, {
    "Name" = join("-", compact([var.aws-resource-name-prefix, "elasticache"]))
  })

  ingress {
    protocol    = "tcp"
    from_port   = "0"
    to_port     = "65535"
    description = "Traffic to AWS"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }
  egress {
    protocol    = "tcp"
    from_port   = "0"
    to_port     = "65535"
    description = "Traffic from AWS"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }
}

resource "aws_vpc_endpoint" "elasticache" {
  count = lookup(coalesce(var.create-endpoints, {}), "elasticache", false) ? 1 : 0

  vpc_id            = var.vpc-id
  service_name      = "com.amazonaws.${var.aws-region}.elasticache"
  vpc_endpoint_type = "Interface"

  security_group_ids = aws_security_group.elasticache_endpoint.*.id

  subnet_ids          = flatten(var.placement-subnet-ids)
  private_dns_enabled = true

  tags = merge(var.tags, {
    "Name" = join("-", compact([var.aws-resource-name-prefix, "elasticache"]))
  })
}