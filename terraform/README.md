# Terraform: Infrastructure as Code

The code to deploy my Nextcloud server on [DigitalOcean](https://www.digitalocean.com).

## Requirements

- Terraform >= 0.12

## Usage

    terraform init

Required variables:

- DigitalOcean Token: `do_token` 
- DigitalOcean SSH key: `default_ssh_key_name`
- DigitalOcean domain name: `default_domain_name`
