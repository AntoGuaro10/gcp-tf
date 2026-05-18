module "gce_vm_1" {
  source        = "/modules/compute-vm-with-disks"
  project_id    = var.project_id
  zone          = "europe-west4-a"
  name          = "gce-name"
  instance_type = "n2d-standard-2"
  
  network_interfaces = [{
    network    = var.network
    subnetwork = var.subnet
    nat        = false
    addresses  = null
  }]
  service_account        = var.service_account
  service_account_scopes = ["https://www.googleapis.com/auth/cloud-platform", "https://www.googleapis.com/auth/compute", "https://www.googleapis.com/auth/devstorage.full_control"]

  shielded_config = {
    enable_secure_boot = true
    enable_integrity_monitoring = true
    enable_vtpm = true
  }

  boot_disk = {
    image = "projects/rocky-linux-cloud/global/images/rocky-linux-8-v20220317"
    type  = "pd-ssd"
    size  = 30
  }
  metadata          = var.metadata

  labels = {
    "application" = "your label"
  }
}