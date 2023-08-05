terraform {
  cloud {
    organization = "dawsi"

    workspaces {
      name = "terraform-cloud-workspace-dawsi"
    }
  }
}