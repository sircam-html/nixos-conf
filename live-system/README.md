# NixOS Configuration / Pinned Nvidia Drivers 580.159.04

Personal NixOS setup running **Stable 26.05** with KDE Plasma 6 on a hybrid AMD/NVIDIA system.

## System

| Component  | Details                                        |
|------------|------------------------------------------------|
| OS         | NixOS 26.05 (Yarara) x86_64                   |
| Desktop    | KDE Plasma 6.6 (Wayland)                      |
| CPU        | AMD (pstate + schedutil)                      |
| GPU        | NVIDIA GTX 1070 Ti (driver pinned to 580.159.04) |
| Bootloader | systemd-boot + Plymouth (nixos-bgrt theme)    |
| Shell      | Fish (with aliases)                           |

## Structure

- **`configuration.nix`** — System base: bootloader, kernel, networking, services
- **`nvidia.nix`** — NVIDIA driver module (pinned 580.159.04 via mkDriver)
- **`amd-cpu.nix`** — AMD CPU module: pstate, TLP, power management
- **`home.nix`** — User level: all apps managed via Home Manager (100% pure)

## 🚀 Quick Setup (Fresh Machine)

```bash
sudo nixos-generate-config
mkdir -p ~/.config/home-manager
sudo curl -o /etc/nixos/nvidia.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/nvidia.nix \
  && sudo curl -o /etc/nixos/configuration.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/configuration.nix \
  && sudo curl -o /etc/nixos/amd-cpu.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/amd-cpu.nix \
  && curl -o ~/.config/home-manager/home.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/home.nix \
  && curl -o ~/.config/home-manager/fish.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/fish.nix

Run sudo nixos-rebuild switch && home-manager switch (separately or one after the other).


## 🔄 Backup

Use `bu` anytime to push your changes back up.

```bash
bu   # copies all config files to GitHub automatically
```

## Highlights

- NVIDIA driver pinned to `580.159.04` for Pascal GPU stability
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
| `update`   | NixOS + Home Manager full update                 |
| `nr`       | NixOS rebuild switch                             |
| `hm`       | Home Manager switch                              |
| `nv`       | Live NVIDIA 580 driver tracker + mkDriver block  |
| `safe-check` | Hydra pre-update check                         |
| `safe-update`| Update only if Hydra checks pass               |
| `trim`     | Full system cleanup + store optimization         |
| `gc`       | Nix garbage collect                              |
| `dg`       | Delete old generations + update bootloader       |
| `op`       | Nix store optimise                               |
| `cn`       | Edit configuration.nix                           |
| `nn`       | Edit nvidia.nix                                  |
| `an`       | Edit amd-cpu.nix                                 |
| `fn`       | Edit fish.nix (aliases)                          |
| `hn`       | Edit home.nix                                    |
| `ff`       | Fastfetch with custom preset                     |
| `ch`       | List system + user channels                      |
| `ver`      | Show NixOS + Home Manager versions               |
| `ps`       | Restart KDE Plasma shell                         |
| `chrome`   | Run Chrome sandbox (ephemeral)                   |
| `chrome-wipe` | Wipe Chrome sandbox cache                    |
| `code`     | Start OpenCode sandbox (tmux)                    |
| `code-kill`| Stop OpenCode sandbox                            |
| `code-wipe`| Wipe OpenCode sandbox cache                      |
| `servers`  | Start devbox Caddy servers                       |
| `hc`       | hydra-check                                      |
