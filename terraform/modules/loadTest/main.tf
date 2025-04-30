resource "azurerm_user_assigned_identity" "loadtest" {
  name                = var.loadtest.managed_id
  resource_group_name = var.loadtest.resource_group_name
  location            = var.location

  tags = [var.tags]
}
resource "azurerm_load_test" "loadtest" {
  location            = azurerm_resource_group.loadtest.location
  name                = var.loadtest.name
  resource_group_name = azurerm_resource_group.loadtest.name
  description         = "${var.loadtest.name} for var.names.aks_name"
  identity {
    type         = var.loadtest.mid_identity_type
    identity_ids = var.loadtest.identity_ids
  }
  encryption {
    key_url = var.loadtest.key_url
    identity {
      type        = var.loadtest.encryption_mid_identity_type
      identity_id = var.loadtest.encryption_identity_id
    }
  }
  tags = [var.tags]
}
