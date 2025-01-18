#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/ashscool/ProxmoxVE/gitlab/misc/build.func)

# App Default Values
APP="GitLab"
var_tags="gitlab"
var_cpu="4"
var_ram="8192"
var_disk="16"
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
    if [[ ! -f /usr/local/bin/gitlab ]]; then
        msg_error "No ${APP} Installation Found!"
        exit
    fi
    RELEASE=$(wget -q https://gitlab.com/gitlab-org/gitlab-foss/releases/latest -O - | grep "title>Release" | cut -d " " -f 4 | sed 's/^v//')
    msg_info "Updating $APP to ${RELEASE}"
    wget -q https://gitlab.com/gitlab-org/gitlab-foss/releases/download/v$RELEASE/gitlab-$RELEASE-linux-amd64
    systemctl stop gitlab
    rm -rf /usr/local/bin/gitlab
    mv gitlab* /usr/local/bin/gitlab
    chmod +x /usr/local/bin/gitlab
    systemctl start gitlab
    msg_ok "Updated $APP Successfully"
    exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:80${CL}"
