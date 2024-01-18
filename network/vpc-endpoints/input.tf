variable "create-endpoints" {
  description = "Enable/disable the creation of specific endpoints. if the map itself is null, or if an endpoint is not listed it will not be created (default=false)"
  type        = map(bool)
  default = {
    s3              = true
    ssm             = true
    ssm_messages    = true
    ec2_messages    = true
    cloudwatch_logs = true
    secrets_manager = true
    elasticache     = true
  }
}

variable "vpc-id" {
  description = "VPC the endpoints should be created in"
}

variable "aws-resource-name-prefix" {
  description = "Prefix to be used for names or all AWS resources"
  type        = string
  default     = null
}

variable "client-subnet-route-table-ids" {
  description = "IDs of route tables of subnets which shell use the VPC endpoints"
  type        = list(string)
}

variable "placement-subnet-ids" {
  description = "IDs of subnets in which the endpoints are placed into"
  type        = list(string)
}

variable "tags" {
  description = "Tags to be applied to all managed resources"
  type        = map(string)
}

variable "aws-region" {
  type    = string
  default = "eu-central-1"
}