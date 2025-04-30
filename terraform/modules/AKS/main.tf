resource "azurerm_kubernetes_cluster" "aks" {
  name                       = var.aks.name
  location                   = var.location
  resource_group_name        = var.aks.resource_group_name
  dns_prefix                 = var.aks.dns_prefix
  dns_prefix_private_cluster = var.aks.dns_prefix_private_cluster
  automatic_upgrade_channel  = var.aks.automatic_upgrade_channel

  api_server_access_profile {
    authorized_ip_ranges = var.aks.authorized_ip_ranges
  }

  auto_scaler_profile {
    balance_similar_node_groups                   = var.auto_scaler_profile.balance_similar_node_groups
    daemonset_eviction_for_empty_nodes_enabled    = var.auto_scaler_profile.balance_similar_node_groups
    daemonset_eviction_for_occupied_nodes_enabled = var.auto_scaler_profile.daemonset_eviction_for_empty_nodes_enabled
    expander                                      = var.auto_scaler_profile.expander
    ignore_daemonsets_utilization_enabled         = var.auto_scaler_profile.ignore_daemonsets_utilization_enabled
    max_graceful_termination_sec                  = var.auto_scaler_profile.max_graceful_termination_sec
    max_node_provisioning_time                    = var.auto_scaler_profile.max_node_provisioning_time
    max_unready_nodes                             = var.auto_scaler_profile.max_unready_nodes
    max_unready_percentage                        = var.auto_scaler_profile.max_unready_percentage
    new_pod_scale_up_delay                        = var.auto_scaler_profile.new_pod_scale_up_delay
    scale_down_delay_after_add                    = var.auto_scaler_profile.scale_down_delay_after_add
    scale_down_delay_after_delete                 = var.auto_scaler_profile.scale_down_delay_after_delete
    scale_down_delay_after_failure                = var.auto_scaler_profile.scale_down_delay_after_failure
    scan_interval                                 = var.auto_scaler_profile.scan_interval
    scale_down_unneeded                           = var.auto_scaler_profile.scale_down_unneeded
    scale_down_unready                            = var.auto_scaler_profile.scale_down_unready
    scale_down_utilization_threshold              = var.auto_scaler_profile.scale_down_utilization_threshold
    empty_bulk_delete_max                         = var.auto_scaler_profile.empty_bulk_delete_max
    skip_nodes_with_local_storage                 = var.auto_scaler_profile.skip_nodes_with_local_storage
    skip_nodes_with_system_pods                   = var.auto_scaler_profile.skip_nodes_with_system_pods
  }

  azure_active_directory_role_based_access_control {
    tenant_id              = var.rbac.tenant_id
    admin_group_object_ids = [var.rbac.admin_group_object_ids]
    azure_rbac_enabled     = var.rbac.azure_rbac_enabled
  }

  default_node_pool {
    name                          = var.node_pool.name
    node_count                    = var.node_pool.node_count
    vm_size                       = var.node_pool.vm_size
    capacity_reservation_group_id = var.node_pool.capacity_reservation_group_id
    auto_scaling_enabled          = var.node_pool.auto_scaling_enabled    #type MUST be VirutalMachineScaleSets if enabled
    host_encryption_enabled       = var.node_pool.host_encryption_enabled #Should the nodes in the Default Node Pool have host encryption enabled?
    os_disk_size_gb               = var.node_pool.os_disk_size_gb
    max_pods                      = var.node_pool.max_pods
    min_count                     = var.node_pool.min_count
    max_count                     = var.node_pool.max_count
    type                          = var.node_pool.type
  }

  identity {
    type = "SystemAssigned"
  }

  tags = [var.tags]
}


