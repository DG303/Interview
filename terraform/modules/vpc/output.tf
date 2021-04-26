output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "subnet_group" {
  value = module.vpc.database_subnet_group_name
}
