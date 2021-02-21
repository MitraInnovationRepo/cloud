provider "google" {
 credentials = file(var.credentials)
}

#1. Creating the Projects
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

#2. Enable Compute API for the Projects

resource "google_project_service" "host_project" {
  project = module.host_project.out_project_id
  service = "compute.googleapis.com"
}

resource "google_project_service" "service_project_1" {
  project = module.service_project_1.out_project_id
  service = "compute.googleapis.com"
}

resource "google_project_service" "service_project_2" {
  project = module.service_project_2.out_project_id
  service = "compute.googleapis.com"
}

resource "google_project_service" "service_project_3" {
  project = module.service_project_3.out_project_id
  service = "compute.googleapis.com"
}

#3. Enable Shared VPC in Host Projects

resource "google_compute_shared_vpc_host_project" "host_project" {
  project    = module.host_project.out_project_id
  depends_on = [google_project_service.host_project]
}

resource "google_compute_shared_vpc_service_project" "service_project_1" {
  host_project    = module.host_project.out_project_id
  service_project = module.service_project_1.out_project_id

  depends_on = [
    google_compute_shared_vpc_host_project.host_project,
    google_project_service.service_project_1,
  ]
}

resource "google_compute_shared_vpc_service_project" "service_project_2" {
  host_project    = module.host_project.out_project_id
  service_project = module.service_project_2.out_project_id

  depends_on = [
    google_compute_shared_vpc_host_project.host_project,
    google_project_service.service_project_2,
  ]
}

resource "google_compute_shared_vpc_service_project" "service_project_3" {
  host_project    = module.host_project.out_project_id
  service_project = module.service_project_3.out_project_id

  depends_on = [
    google_compute_shared_vpc_host_project.host_project,
    google_project_service.service_project_3,
  ]
}

#4. Create the Network for the Host

resource "google_compute_network" "vpc-network" {
  name                    = "vpc-network"
  auto_create_subnetworks = "true"
  project                 = google_compute_shared_vpc_host_project.host_project.project

  depends_on = [
    google_compute_shared_vpc_service_project.service_project_1,
    google_compute_shared_vpc_service_project.service_project_2,
    google_compute_shared_vpc_service_project.service_project_3
  ]
}

#5. Update Firewall Rules

resource "google_compute_firewall" "vpc-network" {
  name    = "allow-ssh-and-icmp"
  network = google_compute_network.vpc-network.self_link
  project = google_compute_network.vpc-network.project

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }
}
