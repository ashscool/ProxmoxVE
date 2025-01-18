#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/ashscool/ProxmoxVE/gitlab/misc/build.func)
# Copyright (c) 2021-2024 community-scripts ORG
# Author: ashscool
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://about.gitlab.com/install/#debian

# App Default Values
APP="GitLab"
TAGS="gitlab"
var_cpu="2"
var_ram="4096"
var_disk="8"
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

    # Check if installation is present
    if [[ ! -f /opt/gitlab/version.txt ]]; then
        msg_error "No ${APP} Installation Found!"
        exit
    fi

    # Crawling the new version
    RELEASE=$(curl -fsSL https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/stretch/gitlab-ce-*.deb | grep -oP 'gitlab-ce-\K[0-9.]+')
    if [[ "${RELEASE}" != "$(cat /opt/gitlab/version.txt)" ]]; then
        msg_info "Updating $APP to v${RELEASE}"

        # Stopping Services
        msg_info "Stopping $APP"
        systemctl stop gitlab
        msg_ok "Stopped $APP"

        # Creating Backup
        msg_info "Creating Backup"
        tar -czf "/opt/gitlab_backup_$(date +%F).tar.gz" /etc/gitlab /var/opt/gitlab
        msg_ok "Backup Created"

        # Execute Update
        msg_info "Updating $APP to v${RELEASE}"
        apt-get install --only-upgrade gitlab-ce
        msg_ok "Updated $APP to v${RELEASE}"

        # Starting Services
        msg_info "Starting $APP"
        systemctl start gitlab
        msg_ok "Started $APP"

        # Cleaning up
        msg_info "Cleaning Up"
        rm -rf /tmp/* /var/tmp/*
        msg_ok "Cleanup Completed"

        # Last Action
        echo "${RELEASE}" >/opt/gitlab/version.txt
        msg_ok "Update Successful"
    else
        msg_ok "No update required. GitLab is already at v${RELEASE}"
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
