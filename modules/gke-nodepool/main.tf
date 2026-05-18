locals {
  service_account_email = (
    var.node_service_account_create
    ? (
      length(google_service_account.service_account) > 0
      ? google_service_account.service_account[0].email
      : null
    )
    : var.node_service_account
  )
  service_account_scopes = (
    length(var.node_service_account_scopes) > 0
    ? var.node_service_account_scopes
    : (
      var.node_service_account_create
      ? ["https://www.googleapis.com/auth/cloud-platform"]
      : [
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/monitoring.write"
      ]
    )
  )
  node_taint_effect = {
    "NoExecute"        = "NO_EXECUTE",
    "NoSchedule"       = "NO_SCHEDULE"
    "PreferNoSchedule" = "PREFER_NO_SCHEDULE"
  }
  # The taint is added to match the one that
  # GKE implicitly adds when Windows node pools are created.
  win_node_pools_taint = (
    var.node_image_type == null
    ? []
    : length(regexall("WINDOWS", var.node_image_type)) > 0
    ? [
      {
        "key"    = "node.kubernetes.io/os"
        "value"  = "windows"
        "effect" = local.node_taint_effect.NoSchedule
      }
    ]
    : []
  )
  node_taints = concat(local.win_node_pools_taint)
}

resource "google_service_account" "service_account" {
  count        = var.node_service_account_create ? 1 : 0
  project      = var.project_id
  account_id   = "tf-gke-${var.name}"
  display_name = "Terraform GKE ${var.cluster_name} ${var.name}."
}

resource "google_container_node_pool" "nodepool" {
  provider = google-beta

  project  = var.project_id
  cluster  = var.cluster_name
  location = var.location
  name     = var.name

  initial_node_count = var.initial_node_count
  max_pods_per_node  = var.max_pods_per_node
  node_count         = var.autoscaling_config == null ? var.node_count : null
  node_locations     = var.node_locations
  version            = var.gke_version

  node_config {
    disk_size_gb      = var.node_disk_size
    disk_type         = var.node_disk_type
    image_type        = var.node_image_type
    labels            = var.node_labels
    resource_labels   = try(var.resource_labels, null)
    local_ssd_count   = var.node_local_ssd_count
    machine_type      = var.node_machine_type
    metadata          = var.node_metadata
    min_cpu_platform  = var.node_min_cpu_platform
    oauth_scopes      = local.service_account_scopes
    preemptible       = var.node_preemptible
    service_account   = local.service_account_email
    tags              = var.node_tags
    boot_disk_kms_key = var.node_boot_disk_kms_key

    dynamic "taint" {
      for_each = var.taints
      content {
        key    = taint.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    dynamic "reservation_affinity" {
      for_each = var.reservation_name != null ? [var.reservation_name] : []
      iterator = config
      content {
        consume_reservation_type = "SPECIFIC_RESERVATION"
        key                      = "compute.googleapis.com/reservation-name"
        values                   = [try(config.value, null)]
      }
    }

    dynamic "guest_accelerator" {
      for_each = var.node_guest_accelerator
      iterator = config
      content {
        type  = config.key
        count = config.value
      }
    }

    dynamic "sandbox_config" {
      for_each = (
        var.node_sandbox_config != null
        ? [var.node_sandbox_config]
        : []
      )
      iterator = config
      content {
        sandbox_type = config.value
      }
    }

    dynamic "shielded_instance_config" {
      for_each = (
        var.node_shielded_instance_config != null
        ? [var.node_shielded_instance_config]
        : []
      )
      iterator = config
      content {
        enable_secure_boot          = config.value.enable_secure_boot
        enable_integrity_monitoring = config.value.enable_integrity_monitoring
      }
    }

    workload_metadata_config {
      mode = var.workload_metadata_config
    }

    dynamic "kubelet_config" {
      for_each = var.kubelet_config != null ? [var.kubelet_config] : []
      iterator = config
      content {
        cpu_manager_policy   = config.value.cpu_manager_policy
        cpu_cfs_quota        = config.value.cpu_cfs_quota
        cpu_cfs_quota_period = config.value.cpu_cfs_quota_period
      }
    }

   linux_node_config {
    sysctls = var.linux_node_config_sysctls
    cgroup_mode = var.cgroup_mode
    }
  }

  dynamic "autoscaling" {
    for_each = var.autoscaling_config != null ? [var.autoscaling_config] : []
    iterator = config
    content {
      min_node_count = try(config.value.min_node_count, null)
      max_node_count = try(config.value.max_node_count, null)

      total_min_node_count = try(config.value.total_min_node_count, null)
      total_max_node_count = try(config.value.total_max_node_count, null)

    }
  }

  dynamic "management" {
    for_each = var.management_config != null ? [var.management_config] : []
    iterator = config
    content {
      auto_repair  = config.value.auto_repair
      auto_upgrade = config.value.auto_upgrade
    }
  }

  dynamic "upgrade_settings" {
    for_each = var.upgrade_config != null ? [var.upgrade_config] : []
    iterator = config
    content {
      max_surge       = config.value.max_surge
      max_unavailable = config.value.max_unavailable
    }
  }

  lifecycle {
    ignore_changes = [ initial_node_count, node_config[0].kubelet_config ]
  }
}
