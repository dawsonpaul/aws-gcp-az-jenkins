terraform {
  cloud {
    organization = "dawsi"

    workspaces {
      name = "aws-waf-demo-jenkins"
    }
  }
}