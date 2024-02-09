output "vpc-id" {
  value = aws_vpc.this.id
}

output "public-subnets" {
  value = module.public-subnet.subnets
}

output "private-subnets" {
  value = module.private-subnets["private"].subnets
}