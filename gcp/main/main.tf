provider "google" {
  project     = var.var_project
}
module "vpc" {
  source = "../modules/global" 
  env                   = var.var_env
  company               = var.var_company
  var_uc1_public_subnet = var.uc1_public_subnet
  var_uc1_private_subnet= var.uc1_private_subnet
  var_ue1_public_subnet = var.ue1_public_subnet
  var_ue1_private_subnet= var.ue1_private_subnet
}
module "uc1" {
  source                = "../modules/uc1"
  network_self_link     = module.vpc.out_vpc_self_link
  subnetwork1           = module.uc1.uc1_out_public_subnet_name
  env                   = var.var_env
  company               = var.var_company
  var_uc1_public_subnet = var.uc1_public_subnet
  var_uc1_private_subnet= var.uc1_private_subnet
}
module "ue1" {
  source                = "../modules/ue1"
  network_self_link     = module.vpc.out_vpc_self_link
  subnetwork1           = module.ue1.ue1_out_public_subnet_name
  env                   = var.var_env
  company               = var.var_company
  var_ue1_public_subnet = var.ue1_public_subnet
  var_ue1_private_subnet= var.ue1_private_subnet
}
######################################################################
# Display Output Public Instance
######################################################################
output "uc1_public_address"  { value = module.uc1.uc1_pub_address}
output "uc1_private_address" { value = module.uc1.uc1_pri_address}
output "ue1_public_address"  { value = module.ue1.ue1_pub_address}
output "ue1_private_address" { value = module.ue1.ue1_pri_address}
output "vpc_self_link" { value = module.vpc.out_vpc_self_link}