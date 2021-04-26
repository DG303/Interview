module "vpc" {
  source = "./modules/vpc"
}

module "eks" {
  source = "./modules/eks"

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  cluster-name    = "ha-interview-08"
}

module "s3-microservice"{
  source = "./modules/s3-microservice"

}

#module "mysql" {
#  source = "./modules/rds"
#
#  security_groups = [module.eks.role_id]
#  vpc_id          = module.vpc.vpc_id
#  subnet_group    =  module.vpc.subnet_group
#}
