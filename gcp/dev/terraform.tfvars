credentials           = "credentials.json"
folder_id             = "573052883711"
billing_account_id    = "018297-9BA585-3D82C2"
org_id                = "756507711694"

host_project          = { 
        name = "ADL - VPCHostProject"
        id = "adl-vpchostproject-init"
    }

enable_compute_api    = "compute.googleapis.com"

service_project_dev   = {
        name = "ADL - VPCServiceProjectDev"
        id = "adl-vpcserviceprojectdev-init"
}

service_project_qa   = {
        name = "ADL - VPCServiceProjectQA"
        id = "adl-vpcserviceprojectqa-init"
}

vpc_network          = {
        name = "vpc-network"
        routing_mode = "REGIONAL"
}

subnet_1 = {
    name    = "vpc-subnet-1"
    cidr = "192.168.1.0/24"
    region = "us-east1"
}

subnet_2 = {
    name    = "vpc-subnet-2"
    cidr = "192.168.25.0/24"
    region = "us-east1"
}

vpc_router = {
    name = "vpc-router"
}

router_nat = {
    name = "my-router-nat"
}

subnetwork_iam_member = {
    dev    = "user:dev@mitralabs.co.uk"
    qa     = "user:qa@mitralabs.co.uk"
    role   = "roles/compute.networkUser"
}

project_iam_member = {
    dev    = "user:dev@mitralabs.co.uk"
    qa     = "user:qa@mitralabs.co.uk"
    role   = "roles/editor"
}

host_project_iam_member = {
    role   = "roles/owner"
    admin  = "user:networkadmin@mitralabs.co.uk"
}

organization_iam_member = {
    role   = "roles/compute.xpnAdmin"
    member  = "user:networkadmin@mitralabs.co.uk"
}

google_compute_instance_vm_dev = {
    name          = "instance-dev"
    machinetype   = "e2-micro"
    zone          = "us-east1-b"
    image         = "debian-cloud/debian-9"
    startupscript = "../modules/shared-vpc/vm-scripts-dev.sh"
}