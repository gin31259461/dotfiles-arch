#!/usr/bin/env bash

setup_sddm() {
  note "Setting up SDDM (Simple Desktop Display Manager)"

  # Enable SDDM service
  sudo systemctl enable sddm.service
  ok "SDDM service enabled"

  # Provide guidance for configuration
  step "SDDM configuration tips:"
  step "  • System settings: Run 'systemsettings' and navigate to Startup and Shutdown → SDDM Login Screen"
  step "  • Config file: /etc/sddm.conf.d/"
  step "  • Theme directory: /usr/share/sddm/themes/"
  note "To activate SDDM now, restart the display manager:"
  note "  sudo systemctl restart display-manager"
  note "Or reboot to test the login screen"
}
