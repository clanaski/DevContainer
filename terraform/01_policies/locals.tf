locals {
    names = {
        resource_policy_name = "${var.subscription_name} Resource Tagging Policy"
        rgp_inherit_tag_policy_name = "${var.subscription_name} Resource Group Inheritance Policy"
        owner = "ChristinaLanaski"
        platform = "terraform"
    }
}