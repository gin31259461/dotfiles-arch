# VMware

Notes for running Arch Linux + Hyprland as a VMware guest.

<!-- markdownlint-disable -->
<!-- toc -->

- [Known Issues](#known-issues)
- [Enable Extra Mouse Buttons (mouse4/mouse5)](#enable-extra-mouse-buttons-mouse4mouse5)
- [Fix Audio Stuttering](#fix-audio-stuttering)

<!-- tocstop -->
<!-- markdownlint-enable -->

## Known Issues

- **Qt / GTK3 apps** may fail to launch under Hyprland in a VM.
  Electron-based apps generally work.
- **`xdg-desktop-portal-hyprland`** (XDPH) may not function correctly in a VM.
  Try [`xdg-desktop-portal-wlr`](https://archlinux.org/packages/?name=xdg-desktop-portal-wlr)
  (XDPW) as an alternative.
- Enable the VMware option to **pass battery information to guest** so the
  system tray shows correct battery status.

## Enable Extra Mouse Buttons (mouse4/mouse5)

With the VM powered off, add to the `.vmx` file:

```vmx
usb.generic.allowHID = "TRUE"
mouse.vusb.enable = "TRUE"
```

## Fix Audio Stuttering

**1. VMware setting** — add to the `.vmx` file (VM must be powered off):

```vmx
sound.highPriority = "TRUE"
```

**2. WirePlumber ALSA tuning** — create
`~/.config/wireplumber/wireplumber.conf.d/50-alsa-config.conf`:

```bash
mkdir -p ~/.config/wireplumber/wireplumber.conf.d
```

```conf
monitor.alsa.rules = [
  {
    matches = [{ node.name = "~alsa_output.*" }]
    actions = {
      update-props = {
        api.alsa.period-size = 1024
        api.alsa.headroom    = 8192
      }
    }
  }
]
```

Further reading:

- [Audio/Video stuttering, Firefox + PipeWire in VMs](https://bbs.archlinux.org/viewtopic.php?id=280654)
- [PipeWire: Stuttering Audio in Virtual Machine](https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Troubleshooting#stuttering-audio-in-virtual-machine)

