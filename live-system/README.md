```markdown
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
curl -o ~/.config/home-manager/home.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/home.nix
sudo curl -o /etc/nixos/configuration.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/configuration.nix
sudo nixos-rebuild switch && hm
```

Then run `bu` anytime to push your changes back up.

## 🔄 Backup

```bash
bu   # copies home.nix + configuration.nix to GitHub automatically
```

## Highlights

- NVIDIA driver pinned to `580.142` for Pascal GPU stability
- Plymouth animated boot splash with NixOS logo
- US keyboard layout with AltGr international variant for Spanish accents and ñ
- Steam with Proton for gaming
- Auto cleanup of Nix store older than 10 days
- TLP power management optimized for desktop
- Virtualization via libvirt/virt-manager

## Useful Aliases

| Alias      | Description                                      |
|------------|--------------------------------------------------|
| `bu`       | Backup configs to GitHub                         |
| `update`   | Updates system and Home Manager                  |
| `trim`     | Full system cleanup and store optimization       |
| `hm`       | Home Manager switch                              |
| `nr`       | NixOS rebuild switch                             |
| `cn`       | Edit system configuration                        |
| `hn`       | Edit home configuration                          |
| `ff`       | Fastfetch with custom preset                     |
| `gc`       | Nix garbage collect                              |
| `dg`       | Delete old generations and update bootloader     |
| `op`       | Nix store optimise                               |
| `ps`       | Restart KDE Plasma shell                         |
```
