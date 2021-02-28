provider "google" {
  credentials = file(var.credentials)
}

module "shared_vpc" {
  source                                = "../modules/shared-vpc"
  host_project                          = var.host_project
  org_id                                = var.org_id
  folder_id                             = var.folder_id
  billing_account_id                    = var.billing_account_id
  enable_compute_api                    = var.enable_compute_api
  enable_dns_api                        = var.enable_dns_api
  service_project_dev                   = var.service_project_dev
  service_project_qa                    = var.service_project_qa
  vpc_network                           = var.vpc_network
  vpc_router                            = var.vpc_router
  subnet_1                              = var.subnet_1
  subnet_2                              = var.subnet_2
  subnet_3                              = var.subnet_3
  subnet_4                              = var.subnet_4
  router_nat                            = var.router_nat
  subnetwork_iam_member                 = var.subnetwork_iam_member
  project_iam_member                    = var.project_iam_member
  organization_iam_member               = var.organization_iam_member
  host_project_iam_member               = var.host_project_iam_member
  google_compute_instance_vm_dev        = var.google_compute_instance_vm_dev
  subnetwork_public_iam_member          = var.subnetwork_public_iam_member
  google_compute_instance_public_vm_dev = var.google_compute_instance_public_vm_dev
  public_dns_zone                       = var.public_dns_zone
  public_dns_zone_recordset             = var.public_dns_zone_recordset
  google_compute_instance_vm_qa         = var.google_compute_instance_vm_qa
  google_compute_instance_public_vm_qa  = var.google_compute_instance_public_vm_qa
}
