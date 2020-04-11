# nextcloud

[![pipeline status](https://gitlab.com/Madh93/nextcloud/badges/master/pipeline.svg)](https://gitlab.com/Madh93/nextcloud/-/commits/master)

The code to deploy my Nextcloud server on [DigitalOcean](https://www.digitalocean.com).

## Requirements

- Terraform >= 0.12

## Usage

    terraform init

Required variables:

- DigitalOcean Token: `do_token`
- DigitalOcean project name: `default_project_name`
- DigitalOcean SSH key: `default_ssh_key_name`
- DigitalOcean domain name: `default_domain_name`
