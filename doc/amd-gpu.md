# AMD GPU Setup

Post-install checklist for AMD GPU users on Arch Linux + Hyprland. Covers driver
verification, Vulkan, hardware video acceleration, Hyprland environment variables,
and performance monitoring.

<!-- markdownlint-disable -->
<!-- toc -->

- [1. Kernel Driver and Firmware](#1-kernel-driver-and-firmware)
- [2. User-space Drivers and Vulkan](#2-user-space-drivers-and-vulkan)
- [3. Hardware Video Acceleration (VA-API)](#3-hardware-video-acceleration-va-api)
- [4. Hyprland Environment Variables](#4-hyprland-environment-variables)
- [5. Performance Monitoring](#5-performance-monitoring)

<!-- tocstop -->
<!-- markdownlint-enable -->

## 1. Kernel Driver and Firmware

**Verify the kernel is using the `amdgpu` driver:**

```bash
lspci -k | grep -A 3 -E "(VGA|3D)"
```

Expected: `Kernel driver in use: amdgpu`

> For older GCN 1.0 / 2.0 cards the `radeon` driver may be preferred by default.
> Force `amdgpu` by adding the appropriate parameter to your kernel command line:
>
> - GCN 1.0 (Southern Islands): `radeon.si_support=0 amdgpu.si_support=1`
> - GCN 2.0 (Sea Islands): `radeon.cik_support=0 amdgpu.cik_support=1`

**Verify the module is loaded:**

```bash
lsmod | grep amdgpu
```

Make sure the `linux-firmware` package is installed — it provides the GPU
firmware blobs required by `amdgpu`.

## 2. User-space Drivers and Vulkan

Install Mesa, 32-bit libraries (needed for Steam / Proton), and Vulkan tools:

```bash
sudo pacman -S mesa vulkan-radeon lib32-mesa lib32-vulkan-radeon vulkan-tools
```

**Verify Vulkan support:**

```bash
vulkaninfo | grep "deviceName"
```

Expected: your AMD GPU model name. If the output shows `llvmpipe`, the software
fallback is active — check that `vulkan-radeon` is installed and the correct
driver is in use.

## 3. Hardware Video Acceleration (VA-API)

VA-API offloads video decoding to the GPU, which reduces CPU load and improves
power efficiency — especially important on Wayland.

**Install packages:**

```bash
sudo pacman -S libva-mesa-driver libva-utils
```

**Verify VA-API is working:**

```bash
vainfo
```

Expected: a list of supported profiles and entrypoints (e.g. `VAProfileH264Main`,
`VAProfileVP9Profile0`). An empty output or error means the driver is not
active.

## 4. Hyprland Environment Variables

Add the following to `~/.config/hypr/hyprland.conf` to ensure correct Wayland
rendering and Mesa integration:

```conf
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland

# Force GBM backend and Mesa Vulkan driver for AMD
env = GBM_BACKEND,drm
env = __GLX_VENDOR_LIBRARY_NAME,mesa
```

**Optional — enable VRR (FreeSync):**

```conf
misc {
    vrr = 1
}
```

## 5. Performance Monitoring

`amdgpu_top` provides a real-time TUI showing GPU usage, VRAM, clocks, and
power draw.

```bash
sudo pacman -S amdgpu_top
amdgpu_top
```
