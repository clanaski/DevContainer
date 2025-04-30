variable "location" {
    type = "string"
    description = "Location of resources within Azure"
}

variable "linuxappservice" {
  type = object({
    web_app_name = string
    https_only = optional(bool, true)
    client_affinity_enabled = optional(string, null)
    client_certificate_mode = optional(string, null)
    client_certificate_exclusion_paths = optional(string, null)
    public_network_access_enabled = optional(bool, false)
    virtual_network_subnet_id = optional(string, null)
    zip_deploy_file = optional(string, null)

    storage_account = object({
        access_key = optional(string, null)
        account_name = optional(string, null)
        name = optional(string, null)
        share_name = optional(string, null)
        type = optional(string, null)
        mount_path = optional(string, null)
    })

    identity = object({
        type = optional(string, null)
        identity_ids = optional(list(string, null))
    })

    connection_string = object({
      name =  optional(string, null)
      type = optional(string, null)
      value = optional(string, null)
    })

    auth_settings = object({
      enabled = optional(string, null)
    
      active_directory = object({
        client_id = optional(string, null)
        allowed_audiences = optional(string, null)
        client_secret = optional(string, null)
        client_secret_setting_name = optional(string, null)
      })

      additional_login_parameters = optional(string, null)
      allowed_external_redirect_urls = optional(list(string, null))
      default_provider = optional(string, null)
    })

    backup = object({
      name = optional(string, null)

      schedule = object({
        frequency_interval = optional(string, null)
        frequency_unit = optional(string, null)
        keep_at_least_one_backup = optional(bool, false)
        start_time = optional(string, null)
      })
      storage_account_url = optional(string, null)
      enabled = optional(bool, false)
    })
    site_config = object({
      always_on = optional(bool, true)
      api_definition_url = optional(string, null)
      api_management_api_id = optional(string, null)
      app_command_line = optional(string, null)
      container_registry_managed_identity_client_id = optional(string, null)
      container_registry_use_managed_identity = optional(string, null)
      ftps_state = optional(string, null)
      load_balancing_mode = optional(string, null)
      minimum_tls_version = optional(string, null)

      application_stack = object({
        docker_image_name = optional(string, null)
        docker_registry_url = optional(string, null)
        docker_registry_password = optional(string, null)
        dotnet_version = optional(string, null) 
        node_version = optional(string, null)
      })
    })

    app_settings = optional(map(string), null)
  })

}

variable "tags" {
    description = "Platform, owner and subscription tags"
    type        = map(list(string))
}