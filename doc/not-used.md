# Not Used Doc

## Remote Desktop using VNC (wayvnc)

- [wayvnc](https://github.com/any1/wayvnc)

1. Install `wayvnc` from AUR

   ```bash
   paru -S wayvnc
   ```

2. Encryption & Authentication (RSA-AES)

   ```bash
   mkdir ~/.config/wayvnc

   ssh-keygen -m pem -f ~/.config/wayvnc/rsa_key.pem -t rsa -N ""

   nvim ~/.config/wayvnc/config
   ```

3. Setting parameters

   ```conf
   use_relative_paths=true
   address=0.0.0.0
   enable_auth=true
   username=user
   password=****
   rsa_private_key_file=rsa_key.pem
   ```

4. Finally, setting autostart

   ```conf
   exec-once = wayvnc 127.0.0.1 5900 &
   ```

5. Now we can access hyprland using vnc viewer
