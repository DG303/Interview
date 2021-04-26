output "subnet_ids" {
  description = "Subnet IDs for RDS"
  value       = module.test.subnet_ids
}

output "subnet_ranges" {
  description = "Private Subnets ip ranges to create"
  value       = module.test.subnet_ranges
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.test.vpc_id
}
