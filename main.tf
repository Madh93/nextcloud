
# Compute and storage

resource "digitalocean_volume" "nextcloud" {
  name                    = var.volume_name
  region                  = var.droplet_region
  size                    = var.volume_size
  initial_filesystem_type = var.volume_type
  description             = "Nextcloud volume to use as external storage"
}

resource "digitalocean_droplet" "nextcloud" {
  name               = var.droplet_name
  image              = var.droplet_image
  region             = var.droplet_region
  size               = var.droplet_size
  volume_ids         = [digitalocean_volume.nextcloud.id]
  ssh_keys           = [data.digitalocean_ssh_key.default.id]
  private_networking = var.droplet_private_networking
  monitoring         = var.droplet_monitoring
  backups            = var.droplet_backups
  user_data          = local.user_data

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

# Networking

resource "digitalocean_floating_ip" "nextcloud" {
  droplet_id = digitalocean_droplet.nextcloud.id
  region     = digitalocean_droplet.nextcloud.region
}

resource "digitalocean_firewall" "nextcloud" {
  name        = var.firewall_name
  droplet_ids = [digitalocean_droplet.nextcloud.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_record" "nextcloud" {
  domain = data.digitalocean_domain.default.name
  name   = var.record_name
  type   = "A"
  value  = digitalocean_floating_ip.nextcloud.ip_address
  ttl    = var.record_ttl
}

# Project

resource "digitalocean_project_resources" "nextcloud" {
  project = data.digitalocean_project.default.id
  resources = [
    digitalocean_volume.nextcloud.urn,
    digitalocean_droplet.nextcloud.urn,
    digitalocean_floating_ip.nextcloud.urn
  ]
}
