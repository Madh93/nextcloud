data "digitalocean_project" "default" {
  name = var.default_project_name
}

data "digitalocean_ssh_key" "default" {
  name = var.default_ssh_key_name
}

data "digitalocean_domain" "default" {
  name = var.default_domain_name
}
