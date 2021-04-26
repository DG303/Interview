module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name = "terraform-test-bds"

  cidr = "10.0.0.0/16"

  azs                 = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets      = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  database_subnets    = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
#  elasticache_subnets = ["10.0.31.0/24", "10.0.32.0/24", "10.0.33.0/24"]
#  intra_subnets       = ["10.0.41.0/24", "10.0.42.0/24", "10.0.43.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  manage_default_route_table = true
  default_route_table_tags   = { DefaultRouteTable = true }

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true

  tags = {
    Terraform   = "true"
    Name        = "ha-interview-08"
    Environment = "EKS"
    "kubernetes.io/cluster/ha-interview-08" = "shared"
  }
}

