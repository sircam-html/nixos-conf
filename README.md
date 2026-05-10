# NixOS Configuration

Personal NixOS setup running **26.05pre** with KDE Plasma 6 on a hybrid AMD/NVIDIA system.

## System

| Component | Details |
|-----------|---------|
| OS | NixOS 26.05pre |
| Desktop | KDE Plasma 6 (Wayland) |
| CPU | AMD (pstate + schedutil) |
| GPU | NVIDIA (pinned driver 580.142) |
| Bootloader | systemd-boot + Plymouth (nixos-bgrt theme) |
| Shell | Fish |

## Structure

- **`configuration.nix`** — System level: drivers, services, kernel, hardware
- **`home.nix`** — User level: all apps managed via Home Manager (100% pure)

## Highlights

- NVIDIA driver pinned to `580.142` for stability
- Plymouth animated boot splash with NixOS logo
- Flatpak enabled for sandboxed apps (Bottles)
- Steam with Proton for gaming
- Auto cleanup of Nix store older than 10 days
- TLP power management optimized for desktop
- Virtualization via libvirt/virt-manager

## Useful Aliases

| Alias | Description |
|-------|-------------|
| `update` | Updates system, Home Manager and Flatpak apps |
| `ddo` | Launches Dragon's Dogma Online via Bottles |


- Repo mirror: [GitLab](https://gitlab.com/S1RCAM/personal-nix-configuration)
- Repo mirror: [CodeBerg](https://codeberg.org/SIRCAM/nixos-conf)

