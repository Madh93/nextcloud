locals {
  user_data = templatefile("templates/cloud-config.tpl", {
    username = var.droplet_user_data_username,
    password = var.droplet_user_data_password,
    ssh_port = var.droplet_user_data_ssh_port,
    ssh_key  = data.digitalocean_ssh_key.default.public_key
  })
}
