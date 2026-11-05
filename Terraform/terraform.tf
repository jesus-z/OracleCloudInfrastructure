terraform {
  required_version = ">= 1.14, < 2.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.0"
    }
  }
  backend "oci" {}
}

