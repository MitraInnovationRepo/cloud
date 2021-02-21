provider "google" {
 credentials = file(var.credentials)
}

module "host_project" {
  source              = "../modules/projects"
  project_name        = "Host Project"
  project_id          = "hostproject"
  org_id              = var.org_id
  folder_id           = var.folder_id
  billing_account_id  = var.billing_account_id
}

output "host_project_id"  { value = module.host_project.out_project_id }

module "service_project_1" {
  source              = "../modules/projects"
  project_name        = "Service Project - Dev"
  project_id          = "serviceprojectdev"
  org_id              = var.org_id
  folder_id           = var.folder_id
  billing_account_id  = var.billing_account_id
}

output "service_project_1_id"  { value = module.service_project_1.out_project_id }

module "service_project_2" {
  source              = "../modules/projects"
  project_name        = "Service Project - QA"
  project_id          = "serviceprojectqa"
  org_id              = var.org_id
  folder_id           = var.folder_id
  billing_account_id  = var.billing_account_id
}

output "service_project_2_id"  { value = module.service_project_2.out_project_id }

module "service_project_3" {
  source              = "../modules/projects"
  project_name        = "Service Project - PROD"
  project_id          = "serviceprojectprod"
  org_id              = var.org_id
  folder_id           = var.folder_id
  billing_account_id  = var.billing_account_id
}

output "service_project_3_id"  { value = module.service_project_3.out_project_id }
