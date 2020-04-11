#cloud-config
users:
  - name: ${username}
    groups: sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_key}
chpasswd:
  list: |
    ${username}:${password}
timezone: UTC
write_files:
  - path: /etc/apt/apt.conf.d/20auto-upgrades
    permissions: 0600
    owner: root:root
    content: |
      APT::Periodic::Update-Package-Lists "1";
      APT::Periodic::Unattended-Upgrade "1";
      APT::Periodic::AutocleanInterval "7";
      Unattended-Upgrade::Automatic-Reboot "true";
  - path: /etc/systemd/system/apt-daily.timer.d/override.conf
    permissions: 0600
    owner: root:root
    content: |
      [Timer]
      OnCalendar=
      OnCalendar=*-*-* 5:00
      RandomizedDelaySec=0
  - path: /etc/systemd/system/apt-daily-upgrade.timer.d/override.conf
    permissions: 0600
    owner: root:root
    content: |
      [Timer]
      OnCalendar=
      OnCalendar=*-*-* 6:00
      RandomizedDelaySec=0
  - path: /etc/ssh/sshd_config
    permissions: 0600
    owner: root:root
    content: |
      # Use most defaults for sshd configuration.
      Subsystem sftp /usr/lib/openssh/sftp-server
      Port ${ssh_port}
      PermitRootLogin no
      AllowUsers ${username}
      PasswordAuthentication no
      UsePAM yes 
      ChallengeResponseAuthentication no 
      LoginGraceTime 30
      ClientAliveInterval 120
      ClientAliveCountMax 2
      MaxStartUps 3
  - path: /etc/fail2ban/jail.local
    permissions: 0600
    owner: root:root
    content: |
      [INCLUDES]
      before = paths-debian.conf

      [DEFAULT]
      ignoreip = 127.0.0.1/8
      bantime = 604800 # 1 Week
      findtime = 3600 # 1 hour
      maxretry = 2
      backend = auto
      usedns = warn
      logencoding = auto
      filter = %(__name__)s
      protocol = tcp
      chain = INPUT
      port = 0:65535
      banaction = iptables-multiport
      action_ = %(banaction)s[name=%(__name__)s, bantime="%(bantime)s", port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
      action = %(action_)s
      enabled = false

      [sshd]
      enabled = true
      port = ${ssh_port}
      logpath = %(sshd_log)s

      [nextcloud]
      enabled = true
      port = http,https
      filter = nextcloud
      logpath = /mnt/${nextcloud_volume_name}/nextcloud.log
  - path: /etc/fail2ban/filter.d/nextcloud.conf
    permissions: 0600
    owner: root:root
    content: |
      [Definition]
      failregex=^.*Login failed: '?.*'? \(Remote IP: '?<HOST>'?\).*$
      ignoreregex =
  - path: /opt/install.sh
    permissions: 0700
    owner: root:root
    content: |
      #! /bin/bash

      echo -e "\n[1/5] Installing Nextcloud Snap package..."
      export PATH="$PATH:/snap/bin"
      snap install nextcloud --channel=${nextcloud_version}

      echo -e "\n[2/5] Updating PHP memory limit..."
      snap set nextcloud php.memory-limit=512M

      echo -e "\n[3/5] Running Nextcloud installer..."
      nextcloud.manual-install ${nextcloud_username} ${nextcloud_password}

      echo -e "\n[4/5] Configuring external volume for data directory..."
      snap connect nextcloud:removable-media && sleep 10
      sed -i "s|'datadirectory'.*|'datadirectory' => '/mnt/${nextcloud_volume_name}',|" /var/snap/nextcloud/current/nextcloud/config/config.php
      snap disable nextcloud
      cp -r /var/snap/nextcloud/common/nextcloud/data/* /mnt/${nextcloud_volume_name}/
      touch /mnt/${nextcloud_volume_name}/.ocdata
      snap enable nextcloud

      echo -e "\n[5/5] Applying extra settings (Trusted Domains, HTTPS, etc.)..."
      nextcloud.occ config:system:set auth.bruteforce.protection.enabled --value=true
      nextcloud.occ config:system:set trusted_domains 0 --value=${nextcloud_domain_name}
      nextcloud.enable-https lets-encrypt <<< $'y\n${nextcloud_letsencrypt_email}\n${nextcloud_domain_name}\n'

      echo -e "\nAll done! Nextcloud has been installed and configured successfully."
runcmd:
  - while ! ping -c1 -W1 mirrors.digitalocean.com; do echo "$? exit status - Waiting for internet connection..."; sleep 1; done
  - apt-get update
  - apt-get install -y fail2ban htop ufw unattended-upgrades vim
  - ufw default deny incoming
  - ufw default allow outgoing
  - ufw allow http
  - ufw allow https
  - ufw allow ${ssh_port}
  - echo "y" | ufw enable
  - /opt/install.sh
  - apt-get upgrade -y
