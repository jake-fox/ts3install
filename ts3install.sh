#!/usr/bin/env bash
set -euo pipefail

# TeamSpeak 3 server install script for Ubuntu (installs 3.13.7)
# Run as a normal user with sudo rights:
#   chmod +x install_teamspeak.sh
#   ./install_teamspeak.sh
#
# Notes:
# - Creates a "teamspeak" user (disabled password) if it doesn't exist
# - Downloads and installs TS3 server to /home/teamspeak
# - Accepts the license
# - Creates /etc/systemd/system/teamspeak.service
# - Enables + starts the service
# - Configures UFW ports and enables firewall

TS_VER="3.13.7"
TS_TARBALL="teamspeak3-server_linux_amd64-${TS_VER}.tar.bz2"
TS_URL="https://files.teamspeak-services.com/releases/server/${TS_VER}/${TS_TARBALL}"
TS_USER="teamspeak"
TS_HOME="/home/${TS_USER}"
SERVICE_FILE="/etc/systemd/system/teamspeak.service"

require_sudo() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Please run with sudo:"
    echo "  sudo $0"
    exit 1
  fi
}

apt_update_upgrade() {
  export DEBIAN_FRONTEND=noninteractive
  apt update -y
  apt upgrade -y
}

create_ts_user_if_missing() {
  if id -u "${TS_USER}" >/dev/null 2>&1; then
    echo "User '${TS_USER}' already exists."
  else
    echo "Creating user '${TS_USER}' (disabled password)..."
    adduser --disabled-password --gecos "" "${TS_USER}"
  fi
}

install_ts_files() {
  echo "Installing TeamSpeak ${TS_VER} into ${TS_HOME}..."
  # Ensure home exists and is owned by user
  mkdir -p "${TS_HOME}"
  chown -R "${TS_USER}:${TS_USER}" "${TS_HOME}"

  # Download/extract as teamspeak user
  sudo -u "${TS_USER}" bash -lc "
    set -euo pipefail
    cd ~
    wget -q --show-progress '${TS_URL}'
    tar xvf '${TS_TARBALL}'
    rm -f '${TS_TARBALL}'
    mv teamspeak3-server_linux_amd64/* .
    rmdir teamspeak3-server_linux_amd64
    touch .ts3server_license_accepted
  "
}

create_systemd_service() {
  echo "Creating systemd service at ${SERVICE_FILE}..."
  cat > "${SERVICE_FILE}" <<'EOF'
[Unit]
Description=TeamSpeak 3 Server
After=network.target

[Service]
WorkingDirectory=/home/teamspeak
User=teamspeak
ExecStart=/home/teamspeak/ts3server_startscript.sh start inifile=ts3server.ini
ExecStop=/home/teamspeak/ts3server_startscript.sh stop
PIDFile=/home/teamspeak/ts3server.pid
RestartSec=15
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable teamspeak
  systemctl start teamspeak
}

setup_firewall() {
  echo "Configuring UFW..."
  # UFW is typically preinstalled, but ensure it's present
  if ! command -v ufw >/dev/null 2>&1; then
    apt install -y ufw
  fi

  ufw allow 9987
  ufw allow 30033,10011,10080,10443,41144/tcp

  # Enable ufw (force avoids interactive prompt)
  ufw --force enable
}

show_status() {
  echo
  echo "Done. Service status:"
  systemctl status teamspeak --no-pager || true
  echo
  echo "Listening ports (if ss is available):"
  if command -v ss >/dev/null 2>&1; then
    ss -lntup | grep -E ':(9987|30033|10011|10080|10443|41144)\b' || true
  fi
  echo
  echo "Tip: The first startup token/log is usually in:"
  echo "  ${TS_HOME}/logs/"
}

main() {
  require_sudo
  apt_update_upgrade
  create_ts_user_if_missing
  install_ts_files
  create_systemd_service
  setup_firewall
  show_status
}

main "$@"
