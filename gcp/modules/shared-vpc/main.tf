#1. Create Host Project and enable the compute API
resource "google_project" "host_project" {
  name            = var.host_project.name
  project_id      = var.host_project.id
  folder_id       = var.folder_id
  billing_account = var.billing_account_id
}

resource "google_project_service" "host_project_service" {
  project = google_project.host_project.project_id
  service = var.enable_compute_api
}

#2. Create Service Project - DEV and enable the compute API
resource "google_project" "service_project_dev" {
  name            = var.service_project_dev.name
  project_id      = var.service_project_dev.id
  folder_id       = var.folder_id
  billing_account = var.billing_account_id
}

resource "google_project_service" "service_project_dev_service" {
  project = google_project.service_project_dev.project_id
  service = var.enable_compute_api
}


#3. Create Service Project - QA and enable the compute API
resource "google_project" "service_project_qa" {
  name            = var.service_project_qa.name
  project_id      = var.service_project_qa.id
  folder_id       = var.folder_id
  billing_account = var.billing_account_id
}

resource "google_project_service" "service_project_qa_service" {
  project = google_project.service_project_qa.project_id
  service = var.enable_compute_api
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
  name                            = var.vpc_network.name
  auto_create_subnetworks         = "false"
  project                         = google_compute_shared_vpc_host_project.vpc_host_project.project
  routing_mode                    = var.vpc_network.routing_mode
  delete_default_routes_on_create = true
  depends_on = [
    google_compute_shared_vpc_service_project.vpc_service_project_dev,
    google_compute_shared_vpc_service_project.vpc_service_project_qa
  ]
}

#6. Setup the Private Subnets
resource "google_compute_subnetwork" "subnet_1" {
  name          = var.subnet_1.name
  network       = google_compute_network.vpc-network.id
  ip_cidr_range = var.subnet_1.cidr
  region        = var.subnet_1.region
  project       = google_project.host_project.project_id
}

resource "google_compute_subnetwork" "subnet_2" {
  name          = var.subnet_2.name
  network       = google_compute_network.vpc-network.id
  ip_cidr_range = var.subnet_2.cidr
  region        = var.subnet_2.region
  project       = google_project.host_project.project_id
}

#Setup Public Networks
resource "google_compute_subnetwork" "subnet_3" {
  name          = var.subnet_3.name
  network       = google_compute_network.vpc-network.id
  ip_cidr_range = var.subnet_3.cidr
  region        = var.subnet_3.region
  project       = google_project.host_project.project_id
}

resource "google_compute_subnetwork" "subnet_4" {
  name          = var.subnet_4.name
  network       = google_compute_network.vpc-network.id
  ip_cidr_range = var.subnet_4.cidr
  region        = var.subnet_4.region
  project       = google_project.host_project.project_id
}

#7. Setup the Router
resource "google_compute_router" "vpc_router" {
  name    = var.vpc_router.name
  region  = google_compute_subnetwork.subnet_1.region
  network = google_compute_network.vpc-network.id
  project = google_project.host_project.project_id

  bgp {
    asn = 64514
  }
}

#8. Setup the Cloud NAT
resource "google_compute_router_nat" "vpc_nat" {
  name                               = var.router_nat.name
  router                             = google_compute_router.vpc_router.name
  region                             = google_compute_router.vpc_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  /* subnetwork {
    name                    = google_compute_subnetwork.subnet_2.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  } */
  subnetwork {
    name                    = google_compute_subnetwork.subnet_1.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  project = google_project.host_project.project_id

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

  source_ranges = ["0.0.0.0/0"]

}

#10. IAM Binding - Set Permission to the Subnet 
resource "google_compute_subnetwork_iam_member" "subnet_member_dev" {
  project    = google_project.host_project.project_id
  region     = google_compute_subnetwork.subnet_1.region
  subnetwork = google_compute_subnetwork.subnet_1.name
  role       = var.subnetwork_iam_member.role
  member     = var.subnetwork_iam_member.dev
}

resource "google_compute_subnetwork_iam_member" "subnet_member_qa" {
  project    = google_project.host_project.project_id
  region     = google_compute_subnetwork.subnet_2.region
  subnetwork = google_compute_subnetwork.subnet_2.name
  role       = var.subnetwork_iam_member.role
  member     = var.subnetwork_iam_member.qa
}

resource "google_compute_subnetwork_iam_member" "subnet_public_member_dev" {
  project    = google_project.host_project.project_id
  region     = google_compute_subnetwork.subnet_3.region
  subnetwork = google_compute_subnetwork.subnet_3.name
  role       = var.subnetwork_public_iam_member.role
  member     = var.subnetwork_public_iam_member.dev
}

resource "google_compute_subnetwork_iam_member" "subnet_public_member_qa" {
  project    = google_project.host_project.project_id
  region     = google_compute_subnetwork.subnet_4.region
  subnetwork = google_compute_subnetwork.subnet_4.name
  role       = var.subnetwork_public_iam_member.role
  member     = var.subnetwork_public_iam_member.qa
}

#10. IAM Binding - Set Permission to the Project 
resource "google_project_iam_member" "project_member_dev" {
  project = google_project.service_project_dev.project_id
  role    = var.project_iam_member.role
  member  = var.project_iam_member.dev
}

resource "google_project_iam_member" "project_member_qa" {
  project = google_project.service_project_qa.project_id
  role    = var.project_iam_member.role
  member  = var.project_iam_member.qa
}

#11. Add permissions to the Network Admin - Host Project Owner and Shared VPC Network Admin
resource "google_project_iam_member" "project_member_host" {
  project = google_project.host_project.project_id
  role    = var.host_project_iam_member.role
  member  = var.host_project_iam_member.admin
}

resource "google_organization_iam_member" "organization_vpc_admin" {
  org_id = var.org_id
  role   = var.organization_iam_member.role
  member = var.organization_iam_member.member
}


#12. Setup a VM inside one of the Developers Project
resource "google_compute_instance" "service_project_dev_vm" {
  name         = var.google_compute_instance_vm_dev.name
  project      = google_project.service_project_dev.project_id
  machine_type = var.google_compute_instance_vm_dev.machinetype
  zone         = var.google_compute_instance_vm_dev.zone

  boot_disk {
    initialize_params {
      image = var.google_compute_instance_vm_dev.image
    }
  }

  metadata_startup_script = file(var.google_compute_instance_vm_dev.startupscript)

  network_interface {
    network    = google_compute_network.vpc-network.self_link
    subnetwork = google_compute_subnetwork.subnet_1.self_link
  }

  depends_on = [google_compute_shared_vpc_service_project.vpc_service_project_dev]
}

#13. Setup a VM inside one of the Developers Project - Public Subnet
resource "google_compute_instance" "service_project_public_dev_vm" {
  name         = var.google_compute_instance_public_vm_dev.name
  project      = google_project.service_project_dev.project_id
  machine_type = var.google_compute_instance_public_vm_dev.machinetype
  zone         = var.google_compute_instance_public_vm_dev.zone

  boot_disk {
    initialize_params {
      image = var.google_compute_instance_public_vm_dev.image
    }
  }

  metadata_startup_script = file(var.google_compute_instance_public_vm_dev.startupscript)

  network_interface {
    network    = google_compute_network.vpc-network.self_link
    subnetwork = google_compute_subnetwork.subnet_3.self_link
    
    access_config {
      // Ephemeral IP
    }
  }

  depends_on = [google_compute_shared_vpc_service_project.vpc_service_project_dev]
}