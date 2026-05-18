locals {
  nodepools = {
      for np in fileset("nodepools","**/*.yaml") :
      trimsuffix(np, ".yaml") => yamldecode(file("nodepools/${np}"))
  }
}

module "gke_1_nodepool_loop" {
  source             = "/modules/gke-nodepool"
  for_each           = local.nodepools
  name               = each.value.name
  project_id         = var.project_id
  cluster_name       = module.gke_1.name
  location           = module.gke_1.location
  node_machine_type  = each.value.node_machine_type
  initial_node_count = each.value.initial_node_count

  node_preemptible  = each.value.node_preemptible
  max_pods_per_node = 64
  cgroup_mode       = "CGROUP_MODE_V2"
  node_image_type   = "cos_containerd"
  autoscaling_config = {
    min_node_count = try(each.value.min_node_count, null)
    max_node_count = try(each.value.max_node_count, null)

    total_min_node_count = try(each.value.total_min_node_count, null)
    total_max_node_count = try(each.value.total_max_node_count, null)
  }

  node_shielded_instance_config = {
    enable_integrity_monitoring = true
    enable_secure_boot = true
  }

  management_config = {
    auto_repair  = true
    auto_upgrade = false
  }

  node_service_account_create = false
  node_service_account        = var.gke_nodepool_sa
  node_count                  = 1 #per-zone
  node_tags                   = each.value.tags
  taints                      = {
    "${each.value.taint}" = {
      value = each.value.taint_value
      effect = each.value.taint_effect
    }
  }
  node_labels                 = each.value.labels
  node_locations              = each.value.locations
  resource_labels             = try(each.value.resource_labels, null)
  reservation_name            = try(each.value.reservation_name, null)
}
