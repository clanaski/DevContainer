module "tagging_policy" {
    source = "../modules/policies"

    resource_policy_name = local.names.resource_policy_name
    rgp_inherit_tag_policy_name = local.names.rgp_inherit_tag_policy_name
    subscription_id = data.azurerm_subscription.current.id
    subscription_name = lower(data.azurerm_subscription.current.name)
    owner = local.names.owner
    platform = local.names.platform
}