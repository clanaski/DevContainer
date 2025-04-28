# Tagging Requirements for Resources
resource "azurerm_policy_definition" "resource_tag" {
  name         = var.resource_policy_name
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = var.resource_policy_name

  metadata = <<METADATA
    {
    "category": "Tag"
    }

METADATA


  policy_rule = <<POLICY_RULE
 {
    "if": {
      "not": {
        "field": "[concat('tags[', parameters('subscriptionTagName'), ']')]",
        "equals": "[parameters('subscriptionTagValue')]"
      },
      {
        "field": "[concat('tags[', parameters('ownerTagName'), ']')]",
        "equals": "[parameters('ownerTagValue')]"
      },
      {
        "field": "[concat('tags[', parameters('platformTagName'), ']')]",
        "equals": "[parameters('platformTagValue')]"
      },
    }
    "then": {
      "effect": "deny"
    }
  }

POLICY_RULE


  parameters = <<PARAMETERS
 {
     "subscriptionTagName": {
      "type": "String",
      "metadata": {
        "description": "Subscription tag.",
        "displayName": "subscription"
        },
      "defaultValue": [
        "subscription"
        ]
      }
    },
    "subscriptionTagValue": {
      "type": "String",
      "metadata": {
        "description": "Name of subscription the resource is deployed to.",
        "displayName": "Subscription Tag Value"
      }
      "defaultValue": [
        ${var.subscription_name}
      ],
      "allowedValues": [
        "demo",
        "development",
        "integration",
        "operations",
        "production",
        "qa",
        "staging"
        ]
    },
    "ownerTagName": {
      "type": "String",
      "metadata": {
        "description": "Owner tag.",
        "displayName": "Allowed locations"
        "displayName": "owner"
        },
      "defaultValue": [
        "owner"
        ]
      }
    },
    "ownerTagValue": {
      "type": "String",
      "metadata": {
        "description": "Name of team/individual that deployed and owns the resource.",
        "displayName": "Owner Tag Value"
      },
      "defaultValue": [
        "${var.owner}"
        ]
    },
    "platformTagName": {
      "type": "String",
      "metadata": {
        "description": "How the resource was created. Portal or terraform.",
        "displayName": "Allowed locations",
        "displayName": "platform"
        },
      "defaultValue": [
        "platform"
        ],
      }
    },
    "platformTagValue": {
      "type": "String",
      "metadata": {
        "description": "How the resource was created. Portal or terraform.",
        "displayName": "Platform Tag Value"
      },
      "defaultValue": [
        "${var.platform}"
        ],
      "allowedValues": [
        "portal",
        "terraform"
      ]
    }
  }
PARAMETERS
}
resource "azurerm_subscription_policy_assignment" "resource_tag" {
  name                 = "example"
  policy_definition_id = azurerm_policy_definition.resource_tag.id
  subscription_id      = var.subscription_id

  depends_on = [ azurerm_policy_definition.tagging ]
}

#Resources Inherit Tag from RGP If Missing
resource "azurerm_policy_definition" "inherit_rgp_tag" {
  name         = var.rgp_inherit_tag_policy_name
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = var.rgp_inherit_tag_policy_name
  metadata = <<METADATA
    {
    "category": "Tag"
    }

METADATA


 policy_rule = <<POLICY_RULE
{
  "if": {
    "allOf": [
      {
        "field": "[concat('tags[', parameters('subscriptionTagName'), ']')]",
        "exists": "false"
      },
      {
        "value": "[resourceGroup().tags[parameters('subscriptionTagName')]]",
        "notEquals": ""
      },
      {
        "field": "[concat('tags[', parameters('ownerTagName'), ']')]",
        "exists": "false"
      },
      {
        "value": "[resourceGroup().tags[parameters('ownerTagName')]]",
        "notEquals": ""
      },
      {
        "field": "[concat('tags[', parameters('platformTagName'), ']')]",
        "exists": "false"
      },
      {
        "value": "[resourceGroup().tags[parameters('platformTagName')]]",
        "notEquals": ""
      }
    ]
  },
  "then": {
    "effect": "deny"
  }
}
POLICY_RULE



  parameters = <<PARAMETERS
 {
     "subscriptionTagName": {
      "type": "String",
      "metadata": {
        "description": "Subscription tag.",
        "displayName": "subscription"
        },
      "defaultValue": [
        "subscription"
        ]
    },
    "ownerTagName": {
      "type": "String",
      "metadata": {
        "description": "Owner tag.",
        "displayName": "owner"
        },
      "defaultValue": [
        "owner"
        ]
    },
    "platformTagName": {
      "type": "String",
      "metadata": {
        "description": "How the resource was created. Portal or terraform.",
        "displayName": "platform"
        },
      "defaultValue": [
        "platform"
        ]
    }
  }
PARAMETERS
}

resource "azurerm_subscription_policy_assignment" "inherit_rgp_tag" {
  name                 = "example"
  policy_definition_id = azurerm_policy_definition.inherit_rgp_tag.id
  subscription_id      = var.subscription_id
}