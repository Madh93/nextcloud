# Provider

variable "do_token" {
  type        = string
  description = "DigitalOcean Access Token"
}


# Data

variable "default_ssh_key_name" {
  type        = string
  description = "DigitalOcean SSH Key name"
}

variable "default_domain_name" {
  type        = string
  description = "DigitalOcean Domain name"
}


# Main

variable "volume_name" {
  type        = string
  description = "Volume name"
  default     = "nextcloud-data-01"
}

variable "volume_size" {
  type        = number
  description = "Volume size in GiB"
  default     = 30
}

variable "volume_type" {
  type        = string
  description = "Volume filesystem type"
  default     = "ext4"
}

variable "droplet_name" {
  type        = string
  description = "Droplet name"
  default     = "nextcloud-01"
}

variable "droplet_image" {
  type        = string
  description = "Droplet image ID or slug"
  default     = "ubuntu-18-04-x64"
}

variable "droplet_region" {
  type        = string
  description = "Droplet region slug"
  default     = "lon1"
}

variable "droplet_size" {
  type        = string
  description = "Droplet size slug"
  default     = "s-1vcpu-1gb"
}

variable "droplet_private_networking" {
  type        = bool
  description = "Enable droplet private networking"
  default     = true
}

variable "droplet_monitoring" {
  type        = bool
  description = "Enable droplet monitoring"
  default     = true
}

variable "droplet_backups" {
  type        = bool
  description = "Enable droplet backups"
  default     = false
}

variable "droplet_user_data_username" {
  type        = string
  description = "Cloud-init user"
  default     = "sammytheshark"
}

variable "droplet_user_data_password" {
  type        = string
  description = "Cloud-init temporary password"
  default     = "P1easeCH4NGm3"
}

variable "droplet_user_data_ssh_port" {
  type        = number
  description = "Cloud-init custom SSH port"
  default     = 22
}

variable "droplet_user_data_nextcloud_version" {
  type        = string
  description = "Nextcloud snap channel release"
  default     = "17/stable"
}

variable "droplet_user_data_nextcloud_username" {
  type        = string
  description = "Nextcloud admin username"
  default     = "admin"
}

variable "droplet_user_data_nextcloud_password" {
  type        = string
  description = "Nextcloud admin password"
  default     = "CH4NGM3please"
}

variable "droplet_user_data_nextcloud_letsencrypt_email" {
  type        = string
  description = "Let's Encrypt email to enable HTTPS"
  default     = "yourname@example.com"
}

variable "firewall_name" {
  type        = string
  description = "Firewall name"
  default     = "nextcloud"
}

variable "record_name" {
  type        = string
  description = "DNS record name"
  default     = "nextcloud"
}

variable "record_ttl" {
  type        = string
  description = "DNS record time to live in seconds"
  default     = "3600"
}
