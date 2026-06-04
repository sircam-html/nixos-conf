# NixOS Configuration / Pinned Nvidia Drivers 580.142

Personal NixOS setup running **Stable 26.05** with KDE Plasma 6 on a hybrid AMD/NVIDIA system.

## System

| Component  | Details                                        |
|------------|------------------------------------------------|
| OS         | NixOS 26.05 (Yarara) x86_64                   |
| Desktop    | KDE Plasma 6.6 (Wayland)                      |
| CPU        | AMD (pstate + schedutil)                      |
| GPU        | NVIDIA GTX 1070 Ti (driver pinned to 580.142) |
| Bootloader | systemd-boot + Plymouth (nixos-bgrt theme)    |
| Shell      | Fish (with aliases)                           |

## Structure

- **`configuration.nix`** — System level: drivers, services, kernel, hardware
- **`home.nix`** — User level: all apps managed via Home Manager (100% pure)

## 🚀 Quick Setup (Fresh Machine)

One-liner to pull the latest configs from GitHub — no git clone or SSH keys needed:

```bash
sudo nixos-generate-config
curl -o ~/.config/home-manager/home.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/26.05-stable-cfg/home.nix
sudo curl -o /etc/nixos/configuration.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/26.05-stable-cfg/configuration.nix
sudo nixos-rebuild switch && hm
