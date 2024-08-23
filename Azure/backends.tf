terraform {
  cloud {
    organization = "dawsi"

    workspaces {
      name = "azure-waf-demo-jenkins"
    }
  }
}