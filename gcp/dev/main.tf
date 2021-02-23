provider "google" {
 credentials = file(var.credentials)
}

#1. Create Host Project and enable the compute API
resource "google_project" "host_project" {
  name                = "ADL - VPCHostProject"
  project_id          = "adl-vpchostproject"
  folder_id           = var.folder_id
  billing_account     = var.billing_account_id
}

resource "google_project_service" "host_project_service" {
  project = google_project.host_project.project_id
  service = "compute.googleapis.com"
}

#2. Create Service Project - DEV and enable the compute API
resource "google_project" "service_project_dev" {
  name                = "ADL - VPCServiceProjectDev"
  project_id          = "adl-vpcserviceprojectdev"
  folder_id           = var.folder_id
  billing_account     = var.billing_account_id
}

resource "google_project_service" "service_project_dev_service" {
  project = google_project.service_project_dev.project_id
  service = "compute.googleapis.com"
}


#3. Create Service Project - QA and enable the compute API
resource "google_project" "service_project_qa" {
  name                = "ADL - VPCServiceProjectQA"
  project_id          = "adl-vpcserviceprojectqa"
  folder_id           = var.folder_id
  billing_account     = var.billing_account_id
}

resource "google_project_service" "service_project_qa_service" {
  project = google_project.service_project_qa.project_id
  service = "compute.googleapis.com"
}

#4. Enable shared VPC feature for the Projects

resource "google_compute_shared_vpc_host_project" "vpc_host_project" {
  project    = google_project.host_project.project_id
  depends_on = [google_project_service.host_project_service]
}

resource "google_compute_shared_vpc_service_project" "vpc_service_project_dev" {
  host_project    = google_project.host_project.project_id
  service_project = google_project.service_project_dev.project_id

  depends_on = [
    google_compute_shared_vpc_host_project.vpc_host_project,
    google_project_service.service_project_dev_service
  ]
}

resource "google_compute_shared_vpc_service_project" "vpc_service_project_qa" {
  host_project    = google_project.host_project.project_id
  service_project = google_project.service_project_qa.project_id

  depends_on = [
    google_compute_shared_vpc_host_project.vpc_host_project,
    google_project_service.service_project_qa_service
  ]
}

#5. Create the VPC Network with subnets defined
resource "google_compute_network" "vpc-network" {
  name                    = "vpc-network"
  auto_create_subnetworks = "false"
  project                 = google_compute_shared_vpc_host_project.vpc_host_project.project
  routing_mode            = "REGIONAL"
  depends_on = [
    google_compute_shared_vpc_service_project.vpc_service_project_dev,
    google_compute_shared_vpc_service_project.vpc_service_project_qa
  ]
}

#6. Setup the Subnets
resource "google_compute_subnetwork" "subnet_1" {
  name          = "vpc-subnet-1"
  network       = google_compute_network.vpc-network.id
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
}

resource "google_compute_subnetwork" "subnet_2" {
  name          = "vpc-subnet-2"
  network       = google_compute_network.vpc-network.id
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
}

#7. Setup the Router
resource "google_compute_router" "vpc_router" {
  name    = "vpc-router"
  region  = google_compute_subnetwork.subnet_1.region
  network = google_compute_network.vpc-network.id
  project = google_project.host_project.project_id
}

#8. Setup the Cloud NAT
resource "google_compute_router_nat" "vpc_nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.vpc_router.name
  region                             = google_compute_router.vpc_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

#9. Update Firewall Rules
resource "google_compute_firewall" "vpc_network_firewall" {
  name    = "vpc-network-firewall"
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
