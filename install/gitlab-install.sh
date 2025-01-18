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

# Start Installation
function install_gitlab() {
   header_info
   check_container_storage
   check_container_resources
   if [[ ! -f /usr/local/bin/gitlab ]]; then
      msg_error "No ${APP} Installation Found!"
      exit
   fi
   msg_info "Installing GitLab"
   wget -q https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh
   chmod +x script.deb.sh
   ./script.deb.sh
   apt-get install gitlab-ce
   msg_ok "GitLab Installed"
   systemctl enable gitlab
   systemctl start gitlab
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:80${CL}"
