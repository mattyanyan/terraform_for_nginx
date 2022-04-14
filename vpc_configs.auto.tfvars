vpc_configs = {
  name = "welend-vpc",
  cidr = "10.0.0.0/16",
  azs = [
    "ap-east-1a",
    "ap-east-1b",
    "ap-east-1c"
  ],
  enable_dns_hostnames    = true,
  map_public_ip_on_launch = true,
  public_subnet_suffix    = "public",
  public_subnet_tags      = {},
  public_subnets = [
    "10.0.101.0/24",
  ],
  private_subnet_suffix = "private",
  private_subnet_tags   = {},
  private_subnets       = [],
  tags                  = {},
}
