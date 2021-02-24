provider "google" {
  credentials = file(var.credentials)
}

module "shared_vpc" {
  source                  = "../modules/shared-vpc"
  host_project            = var.host_project
  org_id                  = var.org_id
  folder_id               = var.folder_id
  billing_account_id      = var.billing_account_id
  enable_compute_api      = var.enable_compute_api
  service_project_dev     = var.service_project_dev
  service_project_qa      = var.service_project_qa
  vpc_network             = var.vpc_network
  vpc_router              = var.vpc_router
  subnet_1                = var.subnet_1
  subnet_2                = var.subnet_2
  router_nat              = var.router_nat
  subnetwork_iam_member   = var.subnetwork_iam_member
  project_iam_member      = var.project_iam_member
  organization_iam_member = var.organization_iam_member
  host_project_iam_member = var.host_project_iam_member
}
