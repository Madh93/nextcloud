terraform {
  required_version = ">= 0.13"

  required_providers {
    digitalocean = {
      source = "terraform-providers/digitalocean"
      version = "1.22.2"
    }
  }
}
