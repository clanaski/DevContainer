resource "azurerm_resource_group" "linuxapp" {
    name = "LoadTesting-RGP"
    location = var.location 
}

module "linuxapp" {
    source = "../modules/LinuxAppService"

    location = var.location
    tags = locals.tags

    linuxappservice = {
      web_app_name = local.names.web_app_name
      https_only = true

      site_config = {
        minimum_tls_version = local.linuxapp.minimum_tls_version
        application_stack = {
            node_version = local.linuxapp.node_version
        }
      }
    }
}

#  Deploy code from a public GitHub repo
resource "azurerm_app_service_source_control" "sourcecontrol" {
  app_id             = module.linuxapp.id
  repo_url           = "https://github.com/Azure-Samples/nodejs-docs-hello-world"
  branch             = "main"
  use_manual_integration = true
  use_mercurial      = false
}
