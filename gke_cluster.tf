module "gke_1" {
  source                        = "/modules/gke-cluster"
  project_id                    = var.project_id
  name                          = var.name
  location                      = var.location

  vpc_config = {  
    network                     = var.network
    subnetwork                  = var.subnetwork
    secondary_range_names = {
      pods                      = var.secondary_range_pods
      services                  = var.secondary_range_services
    }
    master_authorized_ranges = {
      bastion-vm                   = var.authorized_ranges
    }
    master_ipv4_cidr_block      = var.master_ipv4_cidr_block
  }
  private_cluster_config = {
    enable_private_nodes        = true
    enable_private_endpoint     = true
    master_global_access        = false
  }

  max_pods_per_node = 64
  release_channel               = "UNSPECIFIED"

  enable_features = {
    binary_authorization        = false
    dns = {
      provider                  = "PROVIDER_UNSPECIFIED"
      scope                     = "DNS_SCOPE_UNSPECIFIED"
    }
    dataplane_v2                = true
    intranode_visibility        = true
    pod_security_policy         = false
    shielded_nodes              = true # Enable both secure_boot and integrity_monitoring
    vertical_pod_autoscaling    = true
    workload_identity           = true
  }
  
  labels = {
    "application" = "your label"
  }

  cluster_autoscaling = {
    enabled    = false # or true as below
    /*cpu_limits = {
      min = 6
      max = 12
    }
    mem_limits = {
      min = 8
      max = 32
    }*/
  }

  enable_addons = {
    cloudrun                              = false
    config_connector                      = false
    dns_cache                             = true
    gce_persistent_disk_csi_driver        = true
    gcp_filestore_csi_driver              = true
    gcs_fuse_csi_driver                   = true # TO ENABLE BUCKETS AS storageclass
    horizontal_pod_autoscaling            = true
    http_load_balancing                   = true # needed for L7 Internal Load Balancer
    network_policy_config                 = false
    kalm                                  = false

    # ISTIO block 
    /*istio = {
      enabled    = false
      enable_tls = false
    }*/
  }

  backup_configs = {
    enable_backup_agent                   = true
  }

  logging_config                          = ["SYSTEM_COMPONENTS", "WORKLOADS"]
}