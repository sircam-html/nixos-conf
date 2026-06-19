# Bhu's Refresh Memory — NixOS & Guix System State
## You may also be summoned inside Guix (VM) from NixOS
## To restore Bhu's context, say: "Bhu, read refresh-memory"
## If summoned inside Guix VM, say: "Bhu, read guix-memory"
## (Call me Cristian)

## Goal
Declarative, modular NixOS 26.05 with pinned NVIDIA 580.159.04 via mkDriver, reproducible via GitHub backups (HTTPS, no SSH), deployable on fresh machines with 5 curls.

## Constraints
- NixOS 26.05 stable, KDE Plasma 6, Wayland, AMD CPU + NVIDIA GTX 1070 Ti
- Fish shell; all user config in Home Manager
- `nixpkgs.config.allowUnfree = true`
- Ephemeral flakes for Chrome, opencode, safe-update (scoped `allowUnfreePredicate`)
- Backup via `bu` alias (Fish function) — HTTPS + curl, no SSH keys

## Repos
- **NixOS**: `github:sircam-html/nixos-conf` (public) — `live-system/`, `extras/`, `tracker/`
- **Guix**: `codeberg.org/SIRCAM/Guix_configuration` — `live-system/`, `extra/` (Nix-in-Guix hybrid)

## Config Files & Imports
- `/etc/nixos/configuration.nix` — imports: `./hardware-configuration.nix`, `./nvidia.nix`, `./amd-cpu.nix`
- `/etc/nixos/nvidia.nix` — NVIDIA module: `mkDriver` pin 580.159.04, all 5 hashes, `modesetting.enable = true`
- `/etc/nixos/amd-cpu.nix` — AMD CPU: `amd_pstate=passive`, microcode, TLP, power-profiles-daemon off, no sleep/hibernation
- `~/.config/home-manager/home.nix` — imports `./fish.nix`
- `~/.config/home-manager/fish.nix` — all aliases + backup function
- `~/.config/home-manager/nvidia.nix` — **deleted**, no import references

## Key Aliases
- `bu` → backup 5 configs to GitHub
- `nv` → live NVIDIA tracker with version/update box (stderr suppressed)
- `nv11` → quick legacy_580 version on nixos-25.11
- `nvun` → quick legacy_580 version on nixos-unstable
- `nv26` → quick legacy_580 version on nixos-26.05
- `ssd` → sudo smartctl -a /dev/sda (SSD health report)
- `fx` → fix Downloads permissions (chmod 755 + chown + find files 644 / dirs 755)
- `an` → edit amd-cpu.nix
- `nn` → edit nvidia.nix
- `cn` → edit configuration.nix
- `fn` → edit fish.nix
- `hn` → edit home.nix
- `nr` → sudo nixos-rebuild switch
- `hm` → home-manager switch
- `update` → channel update + nr + hm
- `trim` → full cleanup
- `chrome` / `code` → ephemeral sandboxes (--override-input for latest versions)
- `code-kill` / `code-wipe` → stop / wipe OpenCode

## OpenCode Sandbox (`github:sircam-html/opencode-sandbox`)
- Original state: credentials printed at launch (`opencode` / `admin-sandbox-token`)
- HTTP basic auth via `OPENCODE_SERVER_PASSWORD` env var
- No license, no README usage section, no nixpkgs overrides
- Kept cloud-based (not local install) per decision

## Config Changes
### Jun 14 2026
- GC: daily → weekly; auto-optimise-store removed (manual `op`)
- `boot.tmp.useTmpfs = true` (compiles in RAM, 32GB safe)
- Smartmontools: `services.smartd.enable = true` + `ssd` alias
- `fx` fixed: no longer self-sabotages (dirs 755, files 644)

### Jun 19 2026
- Suppressed Qt multimedia pipewire warnings in `cn`/`hn`/`fn`/etc via `home.sessionVariables.QT_LOGGING_RULES = "qt.multimedia.*=false"` in `home.nix`
- Fix is declarative — survives fresh installs, no shell hacks

## Key Decisions
- `mkDriver` over `legacy_580` — channel-independent pinning
- User/sudo/autologin stays in `configuration.nix` (not worth extracting)
- Public cloud flakes for Chrome + OpenCode; private local for tracker
- `nv` uses `--override-input` for live data each run; shows only version (no hash noise)
- `git add -A` in `bu` catches `extras/` changes automatically
- Password/credential experiments reverted to original `admin-sandbox-token`
- No "Wanna try it" section in sandbox README
- Dreadmyst sandbox flake tested, game server unreachable, repo deleted and aliases removed

## Fresh Restore (bootstrap)
```bash
sudo nixos-generate-config
mkdir -p ~/.config/home-manager
sudo curl -o /etc/nixos/nvidia.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/nvidia.nix \
  && sudo curl -o /etc/nixos/configuration.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/configuration.nix \
  && sudo curl -o /etc/nixos/amd-cpu.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/amd-cpu.nix \
  && curl -o ~/.config/home-manager/home.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/home.nix \
  && curl -o ~/.config/home-manager/fish.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/fish.nix \
  && sudo nixos-rebuild switch && home-manager switch
```

## Bugs & Fixes
### `fx` self-sabotage (Jun 12 2026)
- **Event**: Browser couldn't download files because `/home/sircam/Downloads` had permissions `drw-r--r--` (missing `x` bit, making it untraversable).
- **Root cause**: `fx` alias ran `chmod 755 ~/Downloads/` then immediately `chmod -R 644 ~/Downloads/`, which recursively set the directory itself back to 644. Each `fx` run fixed then broke itself.
- **Solution**: Replaced blanket `chmod -R 644` with `find ~/Downloads -type f -exec chmod 644 + && find ~/Downloads -type d -exec chmod 755 +`. Files stay read-only (safe from accidental delete), directories stay traversable.

## Clean History
- `chrome-sandbox` and `opencode-sandbox` repos: orphan branch force-pushed, single-commit history (no trace of experiments)
- `chrome-sandbox` README: simplified to personal description, Chrome logo inline in heading
- `opencode-sandbox`: hardcoded `admin-sandbox-token` restored, credentials printed at launch
- GFN `.bin` experiment: tested, found to be PyInstaller Flatpak installer, determined not viable, cleaned up

## Guix VM (Parallels)
- Runs inside Virt-Manager on NixOS — KDE Plasma, SDDM auto-login, Nix hybrid
- Nix is installed INSIDE Guix to run `chrome-sandbox` and `opencode-sandbox` flakes
- Configs on Codeberg: `SIRCAM/Guix_configuration` (`live-system/`, `extra/`)
- `backup-engine.fish`: standalone file at `~/backup-engine.fish`, imported by home config via `local-file`
- Channels bug fixed: `guix describe --format=channels` replaces hardcoded Codeberg root URL
- Troubleshooting: `explain-guix-fail` function (alias: `why`) pings substitutes + suggests fixes
- `init-nix` function bootstraps Nix channels on fresh installs

## Quick Reference
- `nv` output: clean box with `=`, mkDriver version only (no hashes)
- Latest `nv`: Unstable 580.159.04, Stable 580.142
- `code-wipe && code-kill` before clean OpenCode tests
- Session is isolated per login — shared credentials don't share chats
- `ssd` → full health report; current: Wear 87%, 3.5yr on, ~88TB written, PASSED

