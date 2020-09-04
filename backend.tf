terraform {
  backend "s3" {
    bucket = "mhdez"
    key    = "terraform/nextcloud/terraform.tfstate"
    region = "eu-west-1"
  }
}
