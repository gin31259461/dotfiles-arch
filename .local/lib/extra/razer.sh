#!/usr/bin/env bash

set_razer_group() {
  if ! groups "$USER" | grep -q "\bopenrazer\b"; then
    sudo gpasswd -a "$USER" openrazer
    note "Please log out and back in for group changes to take effect"
  fi
}

# troubleshooting: https://github.com/openrazer/openrazer/wiki/Troubleshooting
build_kernal_module() {
  note "Building Razer kernel module"
  sudo dkms install $(ls /usr/src/ | grep openrazer | sort -V | tail -n 1 | sed 's/\(openrazer-driver\)-\(.*\)/\1\/\2/')
  ok "Razer kernel module built and installed"
}

setup_razer() {
  set_razer_group
  build_kernal_module

  systemctl --user enable openrazer-daemon.service
  ok "Setup Razer complete"
}
