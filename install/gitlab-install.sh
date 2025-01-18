#!/usr/bin/env bash

# Copyright (c) 2021-2024 community-scripts ORG
# Author: [YourUserName]
# License: MIT
# Source: [SOURCE_URL]

# Import Functions and Setup
source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

# Installing Dependencies
msg_info "Installing Dependencies"
$STD apt-get install -y \
  curl \
  sudo \
  mc \
  ca-certificates \
  lsb-release \
  wget \
  unzip
msg_ok "Installed Dependencies"

# Setting up GitLab
msg_info "Setting up GitLab"
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
$STD apt-get install -y gitlab-ce
msg_ok "Installed GitLab"

# Setting up Database for GitLab (MySQL)
msg_info "Setting up Database"
DB_NAME="gitlab_db"
DB_USER="gitlab_user"
DB_PASS=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c13)
$STD mysql -u root -e "CREATE DATABASE $DB_NAME;"
$STD mysql -u root -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED WITH mysql_native_password AS PASSWORD('$DB_PASS');"
$STD mysql -u root -e "GRANT ALL ON $DB_NAME.* TO '$DB_USER'@'localhost'; FLUSH PRIVILEGES;"
{
    echo "GitLab Credentials"
    echo "Database User: $DB_USER"
    echo "Database Password: $DB_PASS"
    echo "Database Name: $DB_NAME"
} >> ~/gitlab-creds
msg_ok "Set up Database"

# Finalizing GitLab Installation
msg_info "Finalizing GitLab Installation"
gitlab-ctl reconfigure
msg_ok "GitLab Installation Complete"

# Cleanup
msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
rm -f /tmp/* /var/tmp/*
msg_ok "Cleaned"

motd_ssh
customize
