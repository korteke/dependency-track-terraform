module "base-network" {
  source                                      = "cn-terraform/networking/aws"
  name_prefix                                 = "dt-networking"
  vpc_cidr_block                              = "192.168.0.0/16"
  availability_zones                          = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets_cidrs_per_availability_zone  = ["192.168.0.0/19", "192.168.32.0/19", "192.168.64.0/19"]
  private_subnets_cidrs_per_availability_zone = ["192.168.128.0/19", "192.168.160.0/19", "192.168.192.0/19"]
}

module "dt" {
  source              = "../../"
  name_prefix         = "dt"
  region              = "eu-west-1"
  vpc_id              = module.base-network.vpc_id
  public_subnets_ids  = module.base-network.public_subnets_ids
  private_subnets_ids = module.base-network.private_subnets_ids
  db_instance_number  = 1
  db_instance_size    = "db.t4g.medium"
  enable_ssl          = false
  lb_https_ports      = {}
  lb_http_ports = {
    default = {
      listener_port         = 80
      target_group_port     = 9000
      target_group_protocol = "HTTP"
    }
  }
}
