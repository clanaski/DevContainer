
variable "loadtest" {
  description = "All configurations for the load test resource"
  type = object({
    name                        = var.name
    resource_group              = var.resource_group_name
    mid_identity_type           = var.mid_identity_type
    identity_id                 = var.identity_ids
    key_url                     = var.key_url
    encryption_mid_idenity_type = var.encryption_mid_idenity_type
    encryption_idenity_id       = var.encryption_identity_id
  })
}

variable "tags" {
  description = "Platform, owner and subscription tags"
  type        = map(list(string))
}

variable "location" {
  type        = string
  description = "Location of resources within Azure"
}