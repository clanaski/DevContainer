locals {

    names = {
        aks = "TestAKS"
        aks_resource_group_name = "AKS-TEST-RGP"
    }

    aks = {
        vm_size = "Standard_D2_v2"
    }
    
    loadtest = {
        name = "${local.names.aks}LoadTest"
        key_url = "https://test.com"
    }


    tags = {
        "platform" = ["terraform"]
        "owner" = ["ChristinaLanaski"]
        "subscription" = ["development"]
    }
}