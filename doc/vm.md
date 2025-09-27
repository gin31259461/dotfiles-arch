# VMware

## Known issues

1. some `qt` or `gtk3` based app may not be able to run on hyprland, `electron`
   based app seems to work well so far
2. the app not using `qt`, `gtk3`, `electron` lib may also not be able to run on
   hyprland
3. [`xdg-desktop-portal-hyprland`](https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal-hyprland/)
   (XDPH) may not working properly, you can try
   [`xdg-desktop-portal-wlr`](https://archlinux.org/packages/?name=xdg-desktop-portal-wlr)
   (XDPW)

## Note

- enable vmware to pass battery information to guest devices.

## Enable extra mouse actions (mouse5, mouse6)

Add the following configuration to vmx file (make sure the vm is power off).

```vmx
usb.generic.allowHID = "TRUE"
mouse.vusb.enable = "TRUE"
```

## Fix startup stuttering

Add the following configuration to vmx file (make sure the vm is power off).

```vmx
sound.highPriority = "TRUE"
```

Configure `wireplumber`

```bash
mkdir -p ~/.config/wireplumber/wireplumber.conf.d/
cd ~/.config/wireplumber/wireplumber.conf.d
```

Then make ~/.config/wireplumber/wireplumber.conf.d/50-alsa-config.conf in an
editor and add:

```conf
monitor.alsa.rules = [
  {
    matches = [
      # This matches the value of the 'node.name' property of the node.
      {
        node.name = "~alsa_output.*"
      }
    ]
    actions = {
      # Apply all the desired node specific settings here.
      update-props = {
        api.alsa.period-size   = 1024
        api.alsa.headroom      = 8192
      }
    }
  }
]
```

Other stuttering problem refer to following link:

- [Audio/Videao stuttering/crackling, Firefox + PipeWire in VMs](https://bbs.archlinux.org/viewtopic.php?id=280654)
- [Pipewire: Stuttering Audio (in Virtual Machine)](https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Troubleshooting#stuttering-audio-in-virtual-machine)
