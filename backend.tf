terraform {
  required_version = ">= 0.12.20"

  backend "s3" {
    bucket = "mhdez"
    key    = "terraform/nextcloud/terraform.tfstate"
    region = "eu-west-1"
  }
}
