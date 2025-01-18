#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/ashscool/ProxmoxVE/gitlab/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster) | Co-Author: Rogue-King
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://about.gitlab.com/

# App Default Values
APP="GitLab"
var_tags="gitlab"
var_cpu="4"
var_ram="8192"
var_disk="50"
var_os="debian"
var_version="12"
var_unprivileged="1"

# App Output & Base Settings
header_info "$APP"
base_settings

# Core
variables
color
catch_errors

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y openssh-server
$STD apt-get install -y ca-certificates
$STD apt-get install -y perl
msg_ok "Installed Dependencies"

msg_info "Installing GitLab"
wget -q https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh
chmod +x script.deb.sh
./script.deb.sh
$STD apt-get install gitlab-ce
msg_ok "GitLab Installed"

msg_info "Configuring GitLab"
# Configure GitLab as per your environment, e.g. ports, etc.
gitlab-ctl reconfigure

msg_info "Starting GitLab"
systemctl enable gitlab
systemctl start gitlab

msg_ok "GitLab is now running!"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
