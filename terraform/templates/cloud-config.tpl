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
  - systemctl daemon-reload
  - systemctl restart fail2ban sshd unattended-upgrades
  - apt-get upgrade -y
