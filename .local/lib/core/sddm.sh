#!/usr/bin/env bash

USERNAME=$(whoami)
SDDM_CONFIG_DIR="/etc/sddm.conf.d"

write_sddm_config() {
  sudo bash -c "cat <<EOF > $SDDM_CONFIG_DIR/autologin.conf
[Autologin]
User=$USERNAME
Session=hyprland
EOF"

}

setup_sddm() {
  if pacman -Qi sddm &>/dev/null; then
    ok "sddm is already installed."
    sudo systemctl enable sddm.service

    if [[ ! -d "$SDDM_CONFIG_DIR" ]]; then
      sudo mkdir -p "$SDDM_CONFIG_DIR"
    fi

    write_sddm_config

    ok "Setup sddm complete."
  else
    warn "sddm is not installed. skipping sddm configuration."
    exit 0
  fi

}
