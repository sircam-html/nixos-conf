# NixOS Configuration / Pinned Nvidia Drivers 580.196.07

Personal NixOS setup running **Stable 26.05** with KDE Plasma 6 on a hybrid AMD/NVIDIA system.

## System

| Component  | Details                                        |
|------------|------------------------------------------------|
| OS         | NixOS 26.05 (Yarara) x86_64                   |
| Desktop    | KDE Plasma 6.6 (Wayland)                      |
| CPU        | AMD (pstate + schedutil)                      |
| GPU        | NVIDIA GTX 1070 Ti (pinned drivers 580) |
| Bootloader | systemd-boot + Plymouth (nixos-bgrt theme)    |
| Shell      | Fish (with aliases)                           |

## Structure

- **`configuration.nix`** — System base: bootloader, kernel, networking, services
- **`nvidia.nix`** — NVIDIA driver module (pinned 580.196.07 via mkDriver)
- **`amd-cpu.nix`** — AMD CPU module: pstate, TLP, power management
- **`fish.nix`** — Fish shell aliases and custom functions
- **`home.nix`** — User level: all apps managed via Home Manager (100% pure)

## 🚀 Quick Setup (Fresh Machine)

```bash
sudo nixos-generate-config
mkdir -p ~/.config/home-manager
sudo curl -o /etc/nixos/nvidia.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/nvidia.nix \
  && sudo curl -o /etc/nixos/configuration.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/configuration.nix \
  && sudo curl -o /etc/nixos/amd-cpu.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/amd-cpu.nix \
  && curl -o ~/.config/home-manager/home.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/home.nix \
  && curl -o ~/.config/home-manager/fish.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/fish.nix \
  && curl -o ~/Documents/refresh-memory.md https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/refresh-memory.md \
  && sudo nixos-rebuild switch
```

### Home Manager (first time only)

`configuration.nix` does not enable Home Manager, so the `home-manager` command
(used by the `hm` alias) does not exist on a fresh system. The last line of the
block above intentionally stops after `nixos-rebuild` — install Home Manager
once with these three commands, matching your NixOS release:

```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

Then apply the user configuration:

```bash
home-manager switch
```

After this, `hm` works as usual. If Home Manager complains about existing files,
run `home-manager switch -b backup`.

> For the development branch instead of 26.05, replace `release-26.05` with
> `master` in the first command. That tracks the next release and will report a
> newer version (e.g. `26.11-pre`).

## Highlights

- NVIDIA driver pinned to `580.196.07` via mkDriver
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
| `chrome-wipe` | Wipe Chrome sandbox cache                     |
| `csteam`   | Start and open Steam console                     |
| `rf`       | exec fish                                        |
| `oc`       | Excute OpenCode AI                               |
| `servers`  | Start devbox Caddy servers                       |
| `Azoth`    | Excute Azoth Launcher                            |
