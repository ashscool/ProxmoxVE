#!/usr/bin/env bash

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y openssh-server
$STD apt-get install -y ca-certificates
$STD apt-get install -y perl
msg_ok "Installed Dependencies"

msg_info "Installing GitLab"
RELEASE=$(wget -q https://gitlab.com/gitlab-org/gitlab-foss/releases/latest -O - | grep "title>Release" | cut -d " " -f 4 | sed 's/^v//')
wget -q https://gitlab.com/gitlab-org/gitlab-foss/releases/download/v$RELEASE/gitlab-$RELEASE-linux-amd64
mv gitlab* /usr/local/bin/gitlab
chmod +x /usr/local/bin/gitlab
adduser --system --group --disabled-password --shell /bin/bash --home /etc/gitlab gitlab > /dev/null
mkdir -p /var/lib/gitlab/{custom,data,log}
chown -R gitlab:gitlab /var/lib/gitlab/
chmod -R 750 /var/lib/gitlab/
chown root:gitlab /etc/gitlab
chmod 770 /etc/gitlab
sudo -u gitlab ln -s /var/lib/gitlab/data/.ssh/ /etc/gitlab/.ssh
msg_ok "Installed GitLab"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/gitlab.service
[Unit]
Description=GitLab (Web-based Git repository manager)
After=syslog.target
After=network.target

[Service]
RestartSec=2s
Type=simple
User=gitlab
Group=gitlab
WorkingDirectory=/var/lib/gitlab
ExecStart=/usr/local/bin/gitlab web --config /etc/gitlab/app.ini
Restart=always
Environment=USER=gitlab HOME=/var/lib/gitlab/data GITLAB_WORK_DIR=/var/lib/gitlab
[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now gitlab
msg_ok "Created Service"

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
