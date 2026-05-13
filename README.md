# NixOS Configurations

Personal NixOS setup running **26.05 Unstable** with KDE Plasma 6 on a hybrid AMD/NVIDIA system.

## System

| Component | Details |
|-----------|---------|
| OS | NixOS 26.05 Unstable |
| Desktop | KDE Plasma 6 (Wayland) |
| CPU | AMD (pstate + schedutil) |
| GPU | NVIDIA Legacy_580 / Pinned 580.142 |
| Bootloader | systemd-boot + Plymouth (nixos-bgrt theme) |
| Shell | Fish (with aliases)|

## Structure

- **`configuration.nix`** — System level: drivers, services, kernel, hardware
- **`home.nix`** — User level: all apps managed via Home Manager (100% pure)

## Highlights

- NVIDIA driver `Legacy_580 / Pinned 580.142` for Pascal GPU for stability
- Plymouth animated boot splash with NixOS logo
- Steam with Proton for gaming
- Auto cleanup of Nix store older than 10 days
- TLP power management optimized for desktop
- Virtualization via libvirt/virt-manager
