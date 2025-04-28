variable "resource_policy_name"{
    type = "string"
    description = "Name of the tagging policy"
}

variable "rgp_inherit_tag_policy_name"{
    type = "string"
    description = "Name of the policy which inherits tags from RGP if missing."
}

variable "subscription_id"{
    type = "string"
    description = "ID of the subscription which the policies will apply to (current subscription)."
}

variable "subscription_name" {
    type = "string"
    description = "Name of the subscription which the polices apply to (current subscription)."
}

variable "owner" {
    type = "string"
    description = "Name of individual/team that deployed/owns the resource."
}

variable "platform" {
    type = "string"
    description = "Platform on which the resource was deployed from (terraform or portal)."
}

# variable "category" {
#     type = "string"
#     description = "Which azure policy category the policy should fall in, ex: Tags, Administrative Templates, Security Options"
# }