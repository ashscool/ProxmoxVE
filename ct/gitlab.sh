#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2024 community-scripts ORG
# Author: [YourUserName]
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: [SOURCE_URL]

# App Default Values
APP="GitLab"
TAGS="gitlab"
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

function update_script() {
    header_info
    check_container_storage
    check_container_resources

    # Check if installation is present | -f for file, -d for folder
    if [[ ! -f /opt/gitlab_version.txt ]]; then
        msg_error "No ${APP} Installation Found!"
        exit
    fi

    # Crawling the new version and checking whether an update is required
    RELEASE=$(curl -fsSL https://packages.gitlab.com/gitlab/gitlab-ce/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3)}')
    if [[ "${RELEASE}" != "$(cat /opt/gitlab_version.txt)" ]] || [[ ! -f /opt/gitlab_version.txt ]]; then
        msg_info "Updating $APP"

        # Stopping Services
        msg_info "Stopping $APP"
        systemctl stop gitlab
        msg_ok "Stopped $APP"

        # Creating Backup
        msg_info "Creating Backup"
        tar -czf "/opt/gitlab_backup_$(date +%F).tar.gz" /opt/gitlab
        msg_ok "Backup Created"

        # Execute Update
        msg_info "Updating $APP to v${RELEASE}"
        curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash
        apt-get install -y gitlab-ce
        msg_ok "Updated $APP to v${RELEASE}"

        # Starting Services
        msg_info "Starting $APP"
        systemctl start gitlab
        sleep 2
        msg_ok "Started $APP"

        # Cleaning up
        msg_info "Cleaning Up"
        rm -rf /tmp/*
        apt-get -y autoremove
        apt-get -y autoclean
        msg_ok "Cleanup Completed"

        # Last Action
        echo "${RELEASE}" >/opt/gitlab_version.txt
        msg_ok "Update Successful"
    else
        msg_ok "No update required. ${APP} is already at v${RELEASE}"
    fi
    exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080${CL}"
