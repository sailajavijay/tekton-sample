
locals {
  zone = {
      z1 = var.zone1
      z2 = var.zone2
  }

  resource_group = {
      for k,v in var.resource_group.config :
          k => ibm_resource_group.rg[k].id
  }

  vpc = {
      for k,v in var.vpc.config :
          k => module.vpc[k].vpc_id[0]

  }

  vpc_nacl = {
    lz_nacl = module.vpc["lz_vpc"].vpc_default_network_acl[0]
  }

  vpc_rt   = {
    lz_rt = module.vpc["lz_vpc"].vpc_default_routing_table[0]
  }

  public_gateway = {
    for k,v in var.public_gateway.config :
          k => module.public_gateway[k].public_gateway_id
  }

  subnet = {
    for k,v in var.subnets.config :
          k => module.subnets[k].subnet_id
  }

  sgs = {
    lz_dsg = module.default_sg["lz_dsg"].security_group_id[0]
  }


  ips = {
    pa-firewall_clients_22_443 = ["209.134.191.19","209.134.191.7","206.253.232.1","209.134.190.192/27","209.134.187.8/29", "209.134.187.16/29", "94.224.44.173","209.134.191.18", "80.68.231.109"]
    pa-firewall_clients_161 = ["209.134.187.8/29","209.134.187.16/29"]
    pa-firewall_client_500 = ["209.134.160.45/32"]
    cis-source-ips = ["131.0.72.0/22", "188.114.96.0/20", "197.234.240.0/22", "198.41.128.0/17", "162.158.0.0/15", "104.16.0.0/13", "104.24.0.0/14", "172.64.0.0/13", "173.245.48.0/20", "103.21.244.0/22", "103.22.200.0/22", "108.162.192.0/18", "141.101.64.0/18", "103.31.4.0/22", "190.93.240.0/20"]
    ibmcloud_mgmt_subnet = ["161.26.0.0/16"]
  }

}