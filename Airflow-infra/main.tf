terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5"
    }
  }
}

provider "google" {
  credentials = file("<YOUR_CREDENTIALS>.json")
  project     = var.project_id
  region      = var.region
}

module "vpc" {
  source      = "./modules/vpc"
  project_id  = var.project_id
  region      = var.region
  vpc_name    = var.vpc_name
  subnet_name = var.subnet_name
  cidr_block  = var.cidr_block
}

module "firewall" {
  source        = "./modules/firewall"
  vpc_name      = module.vpc.vpc_name
  vpc_self_link = module.vpc.vpc_self_link
}
module "service_account" {
  source       = "./modules/service_account"
  project_id   = var.project_id
  sa_name      = var.account_id
  roles        = var.roles
}

module "cloud_sql" {
  source             = "./modules/cloud_sql"
  project_id         = var.project_id
  region             = var.region
  database_instance_name = var.database_instance_name
  root_password      = var.root_password
}

module "gcs_bucket" {
  source      = "./modules/gcs"
  project_id  = var.project_id
  bucket_name = var.bucket_name
}

module "compute_instance" {
  source                = "./modules/compute"
  vm_name               = var.vm_name
  machine_type          = var.machine_type
  zone                  = var.zone
  vm_image              = var.vm_image
  subnet                = module.vpc.subnet_self_link
  service_account_email = module.service_account.email
}