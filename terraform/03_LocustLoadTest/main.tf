#Create Master Node
resource "azurerm_resource_group" "locust" {
  name = "LoadTestRGP"
  location = var.location
}

resource "azurerm_key_vault" "locust" {
  name                        = "locasloadtestkv"
  location                    = azurerm_resource_group.locust.location
  resource_group_name         = azurerm_resource_group.locust.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get", "Set"
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_storage_account" "locust" {
  name                     = "${azurerm_key_vault.locust.name}sa"
  resource_group_name      = azurerm_resource_group.locust.name
  location                 = azurerm_resource_group.locust.location
  account_tier             = "Standard"
  account_replication_type = "GRS" 
}
resource "azurerm_storage_share" "locust" {
  name                 = "testresults"
  storage_account_name = azurerm_storage_account.locust.name
  quota                = 50
}

resource "azurerm_container_group" "master" {
  count               = var.locustWorkerNodes >= 1 ? 1 : 0
  name                = "${random_pet.locust.id}-locust-master"
  location            = azurerm_resource_group.locust.location
  resource_group_name = azurerm_resource_group.locust.name
  ip_address_type     = "Public"
  dns_name_label      = "${random_pet.locust.id}-locust-master"
  os_type             = "Linux"

  container {
    name   = "${random_pet.locust.id}-locust-master"
    image  = var.locustVersion
    cpu    = "2"
    memory = "2"

    commands = [
        "locust",
        "--locustfile",
        "/home/locust/locust/${azurerm_storage_share_file.locustfile.name}",
        "--master",
        "--web-auth",
        "locust:${azurerm_key_vault_secret.locustsecret.value}",
        "--host",
        var.targeturl
    ]

    volume {
        name = "locust"
        mount_path = "/home/locust/locust"

        storage_account_key  = azurerm_storage_account.locust.primary_access_key
        storage_account_name = azurerm_storage_account.locust.name
        share_name           = azurerm_storage_share.locust.name
    }

    ports {
      port     = "8089"
      protocol = "TCP" 
    }

    ports {
      port     = "5557"
      protocol = "TCP" 
    }

  }

  tags     = [local.tags]
}

# Create Worker Nodes
resource "azurerm_container_group" "worker" {
  count               = var.locustWorkerNodes
  name                = "${random_pet.locust.id}-locust-worker-${count.index}"
  location            = var.locustWorkerLocations[count.index % length(var.locustWorkerLocations)]
  resource_group_name = azurerm_resource_group.locust.name
  ip_address_type     = "Public"
  os_type             = "Linux"

  container {
    name   = "${random_pet.locust.id}-worker-${count.index}"
    image  = var.locustVersion
    cpu    = "2"
    memory = "2"

    commands = [
        "locust",
        "--locustfile",
        "/home/locust/locust/${azurerm_storage_share_file.locustfile.name}",
        "--worker",
        "--master-host",
        azurerm_container_group.master[0].fqdn
    ]

    volume {
        name = "locust"
        mount_path = "/home/locust/locust"

        storage_account_key  = azurerm_storage_account.locust.primary_access_key
        storage_account_name = azurerm_storage_account.locust.name
        share_name           = azurerm_storage_share.locust.name
    }

    ports {
      port     = 8089
      protocol = "TCP"
    }

  }

  tags     = [local.tags]
}