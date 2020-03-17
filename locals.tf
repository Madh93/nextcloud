locals {
  user_data = templatefile("templates/cloud-config.tpl", {
    username                    = var.droplet_user_data_username,
    password                    = var.droplet_user_data_password,
    ssh_port                    = var.droplet_user_data_ssh_port,
    ssh_key                     = data.digitalocean_ssh_key.default.public_key,
    nextcloud_version           = var.droplet_user_data_nextcloud_version,
    nextcloud_username          = var.droplet_user_data_nextcloud_username,
    nextcloud_password          = var.droplet_user_data_nextcloud_password,
    nextcloud_letsencrypt_email = var.droplet_user_data_nextcloud_letsencrypt_email,
    nextcloud_volume_name       = replace(var.volume_name, "-", "_"),
    nextcloud_domain_name       = format("%s.%s", var.record_name, var.default_domain_name)
  })
}
