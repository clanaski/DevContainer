locals {
  names = {
    resource_group_name = "LoadTesting-RGP"
    web_app_name = "testlinuxwebapp"
  }

  linuxapp = {
    minimum_tls_version = "1.2"
    node_version = "16-lts"
  }
}