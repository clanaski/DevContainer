resource "azurerm_resource_group" "aks" {
    name = local.name.aks_resource_group_name
    location = var.location
}

module "aks" {
    source = "../modules/AKS"

    subscription_id = data.azurerm_subscription.current.id
    subscription_name = data.azurerm_subscription.current.name
    owner = local.names.owner
    platform = local.names.platform
    location = var.location
    
    aks = {
        name = local.name.aks
        resource_group_name = azurerm_resource_group.aks.name
        dns_prefix = local.aks.dns_prefix
    }

    node_pool = {
      name = "default"
      node_count = 1
      vm_size = local.aks.vm_size
    }

    auto_scaler_profile = null
    rbac = null

    tags = locals.tags
}

module "loadtest" {
    source = "../modules/loadTest"

    location = var.location
    tags = local.tags

    loadtest = {
    tags = local.tags
    name = local.loadtest.name
    resource_group = module.aks.resource_group_name
    mid_idenity_type = "SystemAssigned"
    key_url = local.loadtest.key_url
    }

}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}