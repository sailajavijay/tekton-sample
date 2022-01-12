variable "cloud"          { default = "ic" }
variable "cust_id"        { default = "awx" }
variable "region"         { default = "eu-de" }
variable "zone1"           { default = "eu-de-1" }
variable "zone2"           { default = "eu-de-2" }

variable "size"           { default = "xs"}
variable "common-tags" {
  type = list(string)
  default = ["type:customer", "project:rwsap", "customer:awx"]
}
variable "address_prefixes" {
  description = "List of Prefixes for the vpc"
  type = list(object({
    name     = string
    location = string
    ip_range = string
  }))
  default = []
}

variable "resource_group" {
  default = {
    config = {
      rg1 = { suffix = "rg" }
    }
  }
}
variable "vpc" {
  default = {
    config = {
      lz_vpc = { vpc_suffix = "lz-vpc", rg = "rg1", create_vpc = true, classic_access = false, deaddr_prefix = "manual", nacl_suffix = "nacl-lz-vpc", droutab_suffix =  "rt-lz-vpc", dsg_suffix = "sg-lz-vpc", tags =  ["type:pes", "purpose:lz"] }
    }
  }
}
variable "address_range" {
  default = {
    config = {
      lz_ibm_addr_range_0     = { suffix = "lz-ibm-addr-range-z1", cidr= "172.28.4.0/25", vpc = "lz_vpc", zone = "z1" }
      lz_ibm_addr_range_1     = { suffix = "lz-ibm-addr-range-z2", cidr= "172.29.4.0/25", vpc = "lz_vpc", zone = "z2" }

    }
  }
}
variable "public_gateway" {
  default = {
    config = {
      lz_pg-z1 = { suffix = "pg-lz-vpc-z1", rg = "rg1", vpc = "lz_vpc", zone = "z1"}
      lz_pg-z2 = { suffix = "pg-lz-vpc-z2", rg = "rg1", vpc = "lz_vpc", zone = "z2"}

    }
  }
}
variable "subnets" {
  default = {
    config = {
      lz_vpc_ibm_subnet-z1               = { suffix = "lz-z1-pagw-ibm-subnet", cidr = "172.28.4.0/26", rg = "rg1", vpc = "lz_vpc", zone = "z1", nacl = "lz_nacl", rt = "lz_rt", attach_pg = true, pg = "lz_pg-z1"  }
      lz_vpc_ibm_subnet-z2               = { suffix = "lz-z2-pagw-ibm-subnet", cidr = "172.29.4.0/26", rg = "rg1", vpc = "lz_vpc", zone = "z2", nacl = "lz_nacl", rt = "lz_rt", attach_pg = true, pg = "lz_pg-z2"  }
          }
  }
}

variable "clusters" {
  default = {
    config = {
      cluster1 = {suffix = "awx-cluster", vpc = "lz_vpc", rg = "rg1", zone1 = "z1", zone2 = "z2", z1subnet = "lz_vpc_ibm_subnet-z1", z2subnet = "lz_vpc_ibm_subnet-z2" }
    }
  }
}
variable "vpe" {
  default = {
    config = {
      lz_vpe = { suffix = "lz-ntp-vpe", create_endpoint_gateway = true, rg = "rg1", vpc = "lz_vpc", subnet = "lz_vpc_ibm_service_subnet", target_name = "ibm-ntp-server", target_resource_type = "provider_infrastructure_service", zone = "z1"  }
    }
  }
}
variable "default_sg" {
  default = {
    config = {
      lz_dsg   = { create_security_group = true, suffix = "lz-default-sg", rules = "ibmcloud_mgmt_sgrules", vpc = "lz_vpc", rg = "rg1" }
    }
  }
}

variable "server_sg_dependency" {
  default = ["lz_dsg"]
}


variable "sgrules" {
  default = {
    config = {
      lz_dsg = { create_security_group = false, rg = "rg1", vpc = "lz_vpc", sg = "lz_dsg"
                  rules = [{ name = "out-80", direction  = "outbound", remote = ["ibmcloud_mgmt_subnet"], ip_version = "ipv4", tcp = { port_min = 80, port_max = 80 } },
                           { name = "out-443", direction  = "outbound" , remote = ["ibmcloud_mgmt_subnet"], ip_version = "ipv4", tcp = { port_min = 443, port_max = 443 } },
                           { name = "out-udp-53", direction  = "outbound", remote = ["ibmcloud_mgmt_subnet"], ip_version = "ipv4", udp = { port_min = 53, port_max = 53 } },
                           { name = "out-tcp-8443", direction  = "outbound", remote = ["ibmcloud_mgmt_subnet"], ip_version = "ipv4", tcp = { port_min = 8443, port_max = 8443 } },
                           { name = "out-udp-8443", direction  = "outbound", remote = ["ibmcloud_mgmt_subnet"], ip_version = "ipv4", udp = { port_min = 8443, port_max = 8443 } },
                           { name = "out-tcp-53", direction  = "outbound", remote     = ["ibmcloud_mgmt_subnet"], ip_version = "ipv4", tcp = { port_min = 53, port_max = 53 } }]
      }
    }
  }
}