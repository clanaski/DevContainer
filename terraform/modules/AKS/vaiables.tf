variable "subscription_id" {
  type        = string
  description = "ID of the subscription which the policies will apply to (current subscription)."
}

variable "subscription_name" {
  type        = string
  description = "Name of the subscription which the polices apply to (current subscription)."
}

variable "owner" {
  type        = string
  description = "Name of individual/team that deployed/owns the resource."
}

variable "platform" {
  type        = string
  description = "Platform on which the resource was deployed from (terraform or portal)."
}

variable "location" {
  type        = string
  description = "Location of the resource"
}
variable "tags" {
  description = "Platform, owner and subscription tags"
  type        = map(list(string))
}

variable "rbac" {
  description = "Used if Azure RBAC is configured"
  type = optional(object({
    tenant_id              = optional(string, null)
    admin_group_object_ids = optional(string(list), null)
    azure_rbac_enabled     = optional(bool, true)
  }))
}

variable "aks" {
  description = "All required variables for AKS"
  type = object({
    name                       = string
    resource_group_name        = string
    dns_prefix                 = optional(string, null)
    automatic_upgrade_channel  = optional(string, null)
    dns_prefix_private_cluster = optional(string, null)
  })
}

variable "auto_scaler_profile" {
  description = "Configurations for autoscaling"
  type = object({
    balance_similar_node_groups                   = optional(string, null)
    daemonset_eviction_for_empty_nodes_enabled    = optional(bool, false)
    daemonset_eviction_for_occupied_nodes_enabled = optional(bool, true)
    expander                                      = optional(string, null) #"random"
    ignore_daemonsets_utilization_enabled         = optional(bool, false)
    max_graceful_termination_sec                  = optional(string, null) #"600"
    max_node_provisioning_time                    = optional(string, null) #"15m"
    max_unready_percentage                        = optional(string, null) #"45"
    new_pod_scale_up_delay                        = optional(string, null) #"10s"
    scale_down_delay_after_add                    = optional(string, null) #"10m"
    scale_down_delay_after_delete                 = optional(string, null) #"scan_interval"
    scale_down_delay_after_failure                = optional(string, null) #"3m"
    scan_interval                                 = optional(string, null) #"10s"
    scale_down_unneeded                           = optional(string, null) #"10m"
    scale_down_unready                            = optional(string, null) #"20m"
    scale_down_utilization_threshold              = optional(string, null) #"0.5"
    empty_bulk_delete_max                         = optional(string, null) #"10"
    skip_nodes_with_local_storage                 = optional(bool, true)
    skip_nodes_with_system_pods                   = optional(bool, true)
  })
}

variable "node_pool" {
  description = "Default node pool"
  type = object({
    name                    = string #"default"
    node_count              = string #"1"
    vm_size                 = string #"Standard_D2_v2"
    auto_scaling_enabled    = optional(bool, false)
    host_encryption_enabled = optional(bool, false)
    os_disk_size_gb         = optional(string, null)
    max_pods                = optional(string, null)
    min_count               = optional(string, null)
    max_count               = optional(string, null)
    type                    = optional(string, )
  })
}

