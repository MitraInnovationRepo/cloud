variable "folder_id" {}
variable "billing_account_id" {}
variable "org_id" {}

variable "host_project" {
  type = object({
    name    = string
    id = string
  })
}

variable "enable_compute_api" {}

variable "service_project_dev" {
  type = object({
    name    = string
    id = string
  })
}

variable "service_project_qa" {
  type = object({
    name    = string
    id = string
  })
}

variable "vpc_network" {
  type = object({
    name    = string
    routing_mode = string
  })
}

variable "subnet_1" {
  type = object({
    name    = string
    cidr = string
    region = string
  })
}

variable "subnet_2" {
  type = object({
    name    = string
    cidr = string
    region = string
  })
}

variable "vpc_router" {
  type = object({
    name    = string
  })
}

variable "router_nat" {
  type = object({
    name    = string
  })
}

variable "subnetwork_iam_member" {
  type = object({
    dev    = string
    qa     = string
    role   = string
  })
}

variable "project_iam_member" {
  type = object({
    dev    = string
    qa     = string
    role   = string
  })
}

variable "host_project_iam_member" {
  type = object({
    role   = string
    admin  = string
  })
}

variable "organization_iam_member" {
  type = object({
    role   = string
    member  = string
  })
}