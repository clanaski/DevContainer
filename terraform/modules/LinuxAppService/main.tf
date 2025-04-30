# Create the Linux App Service Plan
resource "azurerm_service_plan" "linuxappservice" {
  name                = var.linuxappservice.name
  location            = var.location
  resource_group_name = var.linuxappservice.resource_group_name
  os_type             = "Linux"
  sku_name            = var.linuxappservice.sku_name
}

resource "azurerm_linux_web_app" "linuxappservice" {
  name                  = var.linuxappservice.web_app_name
  location              = azurerm_service_plan.linuxappservice.location
  resource_group_name   = azurerm_service_plan.linuxappservice.resource_group_name
  service_plan_id       = azurerm_service_plan.linuxappservice.id
  depends_on            = [azurerm_service_plan.appserviceplan]
  https_only            = var.linuxappservice.https_only
  client_affinity_enabled = var.linuxappservice.client_affinity_enabled
  client_certificate_mode = var.linuxappservice.client_certificate_mode
  client_certificate_exclusion_paths = var.linuxappservice.client_certificate_exclusion_paths
  public_network_access_enabled = var.linuxappservice.public_network_access_enabled
  virtual_network_subnet_id = var.linuxappservice.virtual_network_subnet_id
  zip_deploy_file = var.linuxappservice.zip_deploy_file

  storage_account {
    access_key = var.linuxappservice.storage_account.access_key
    account_name = var.linuxappservice.storage_account.account_name
    name = var.linuxappservice.storage_account.name
    share_name = var.linuxappservice.storage_account.share_name
    type = var.linuxappservice.storage_account.type
    mount_path = var.linuxappservice.storage_account.mount_path
  }

  identity {
    type = var.linuxappservice.identity.type
    identity_ids = var.linuxappservice.identity.identity_ids
  }

connection_string {
  name = var.linuxappservice.connection_string.name
  type = var.linuxappservice.connection_string.type
  value = var.linuxappservice.connection_string.value
}

  auth_settings {
    enabled = var.linuxappservice.auth_settings.enabled
    active_directory {
      client_id = var.linuxappservice.auth_settings.client_id
      allowed_audiences = var.linuxappservice.auth_settings.allowed_audiences
      client_secret = var.linuxappservice.auth_settings.client_secret
      client_secret_setting_name = var.linuxappservice.auth_settings.client_secret_setting_name
    }
    additional_login_parameters = var.linuxappservice.auth_settings.additional_login_parameters
    allowed_external_redirect_urls = var.linuxappservice.auth_settings.allowed_external_redirect_urls
    default_provider = var.linuxappservice.auth_settings.default_provider
  }

  backup {
    name = var.linuxappservice.backup.name
    schedule {
      frequency_interval = var.linuxappservice.backup.frequency_interval
      frequency_unit = var.linuxappservice.backup.frequency_unit
      keep_at_least_one_backup = var.linuxappservice.backup.keep_at_least_one_backup
      start_time = var.linuxappservice.backup.start_time
    }
    storage_account_url = var.linuxappservice.backup.storage_account_url
    enabled = var.linuxappservice.backup.enabled
  }

  app_settings = var.linuxappservice.app_settings

  site_config { 
    always_on = var.linuxappservice.site_config.always_on
    api_definition_url = var.linuxappservice.site_config.api_definition_url
    api_management_api_id = var.linuxappservice.site_config.api_management_api_id
    app_command_line = var.linuxappservice.site_config.app_command_line
    container_registry_managed_identity_client_id = var.linuxappservice.site_config.container_registry_managed_identity_client_id
    container_registry_use_managed_identity = var.linuxappservice.site_config.container_registry_use_managed_identity
    ftps_state = var.linuxappservice.site_config.ftps_state
    load_balancing_mode = var.linuxappservice.site_config.load_balancing_mode
    minimum_tls_version = var.linuxappservice.site_config.minimum_tls_version
    application_stack {
      docker_image_name = var.linuxappservice.site_config.docker_image_name
      docker_registry_url = var.linuxappservice.site_config.docker_registry_url
      docker_registry_password = var.linuxappservice.site_config.docker_registry_password
      dotnet_version = var.linuxappservice.site_config.dotnet_version
      node_version = var.linuxappservice.site_config.node_version
    }
  }

  tags = [var.tags]
}