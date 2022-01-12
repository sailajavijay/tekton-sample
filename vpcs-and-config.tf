resource "ibm_resource_group" "rg" {
  for_each = var.resource_group.config
  name = join("-", [ var.cust_id, each.value.suffix ] )
}

module "vpc" {

  for_each                    = var.vpc.config
  source                      = "terraform-ibm-modules/vpc/ibm//modules/vpc"
  version                     = "1.1.1"
  create_vpc                  = each.value.create_vpc
  vpc_name                    = join("-", [var.cust_id, each.value.vpc_suffix])
  resource_group_id           = local.resource_group[each.value.rg]
  classic_access              = each.value.classic_access
  default_address_prefix      = each.value.deaddr_prefix
  default_network_acl_name    = join("-", [var.cust_id, each.value.nacl_suffix])
  default_security_group_name = join("-", [var.cust_id, each.value.dsg_suffix])
  default_routing_table_name  = join("-", [var.cust_id, each.value.droutab_suffix])
  vpc_tags                    = each.value.tags
  address_prefixes            = var.address_prefixes

}

module "address_prefix" {

  for_each = var.address_range.config
  source   = "terraform-ibm-modules/vpc/ibm//modules/vpc-address-prefix"
  version  = "1.1.1"
  name     = join("-", [var.cust_id, each.value.suffix])
  vpc_id   = local.vpc[each.value.vpc]
  location = local.zone[each.value.zone]
  ip_range = each.value["cidr"]

}

module "public_gateway" {

  for_each          = var.public_gateway.config
  source            = "terraform-ibm-modules/vpc/ibm//modules/public-gateway"
  version           = "1.1.1"
  name              = join("-", [var.cust_id, each.value.suffix])
  vpc_id            = local.vpc[each.value.vpc]
  resource_group_id = local.resource_group[each.value.rg]
  location          = local.zone[each.value.zone]
  tags              = var.common-tags

}

module "subnets" {

  depends_on                     = [module.address_prefix]
  for_each                       = var.subnets.config
  source                         = "terraform-ibm-modules/vpc/ibm//modules/subnet"
  version                        = "1.1.1"
  name                           = join("-", [var.cust_id, each.value["suffix"]])
  vpc_id                         = local.vpc[each.value.vpc]
  resource_group_id              = local.resource_group[each.value.rg]
  location                       = local.zone[each.value.zone]
  ip_range                       = each.value.cidr
  subnet_access_control_list     = local.vpc_nacl[each.value.nacl]
  public_gateway                 = each.value["attach_pg"] ? local.public_gateway[each.value.pg]  : null
  routing_table                  = local.vpc_rt[each.value.rt]

}

module "default_sg" {

  for_each              = var.default_sg.config
  source                = "terraform-ibm-modules/vpc/ibm//modules/security-group"
  version               = "1.1.1"
  create_security_group = each.value.create_security_group
  name                  = join("-", [var.cust_id,  each.value.suffix])
  vpc_id                = local.vpc[each.value.vpc]
  resource_group_id     = local.resource_group[each.value.rg]


}


