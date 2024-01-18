# Module "vpc-endpoints"

A configurable module for creation of VPC endpoints within a dedicated VPC.

VPC Endpoints to be created can be configured via variable `create-endpoints`.

Supported / implemented endpoints:
* S3
* SSM
* SSM messages
* EC2 messages
* Cloudwatch logs
* Secrets Manager
* Elasticache