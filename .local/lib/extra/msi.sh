#!/usr/bin/env bash

set_autostart_mcontrolcenter() {
  if [[ -z $HOME/.config/autostart/mcontrolcenter.desktop ]]; then
    cp /usr/share/applications/mcontrolcenter.desktop ~/.config/autostart/mcontrolcenter.desktop
    exit 0
  fi

  warn "mcontrolcenter.desktop already exists in autostart directory, skipping"
}

setup_msi() {
  set_autostart_mcontrolcenter
}
