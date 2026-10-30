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
- **Azoth Launcher**: `github:sircam-html/azoth-launcher` (public) — flake packaging Azoth Launcher (New World fan server) from `github:KyzaBOY/azoth-launcher`; Wails/WebKitGTK 4.1 + Windows patcher, runs via `steam-run` + `umu-launcher`

## Config Files & Imports
- `/etc/nixos/configuration.nix` — imports: `./hardware-configuration.nix`, `./nvidia.nix`, `./amd-cpu.nix`
- `/etc/nixos/nvidia.nix` — NVIDIA module: `mkDriver` pin 580.159.04, all 5 hashes, `modesetting.enable = true`
- `/etc/nixos/amd-cpu.nix` — AMD CPU: `amd_pstate=passive`, microcode, TLP, power-profiles-daemon off, no sleep/hibernation
- `~/.config/home-manager/home.nix` — imports `./fish.nix`
- `~/.config/home-manager/fish.nix` — all aliases + backup function
- `~/.config/home-manager/nvidia.nix` — **deleted**, no import references

## Key Aliases
- `bu` → backup 6 configs + refresh-memory.md to GitHub
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
- `Azoth` → run Azoth Launcher ephemeral: `env GDK_BACKEND=x11 NIXPKGS_ALLOW_UNFREE=1 nix run github:sircam-html/azoth-launcher --impure --refresh --no-write-lock-file`

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
- Suppressed Qt multimedia pipewire warnings via `home.sessionVariables.QT_LOGGING_RULES = "qt.multimedia.*=false"` in `home.nix`
- Fix is declarative — survives fresh installs, no shell hacks

### Jun 20 2026
- Added `systemd.timers.fix-downloads-perms` — daily auto-fix for Downloads permissions (chmod 644 files, 755 dirs, chown sircam:users)
- Suppressed lock file warnings in `chrome` and `code` aliases with `2>/dev/null`
- `refresh-memory.md` now backed up by `bu` and included in bootstrap curls
- Guix config: `backup-engine.fish` channels bug fixed (`guix describe --format=channels`)

### Jun 23-24 2026 — OpenBLAS i686 Crisis (Resolved)
- `nr` after channel bump triggered enormous rebuild: OpenBLAS + numpy + pandas + ffmpeg + Qt3D + QEMU + coolercontrold
- Build interrupted at 96% (user cancelled, 9:30pm deadline); nix-daemon restarted, blackout
- `gc && dg && op` chain triggered home-manager rebuild from scratch (cache nuked by `dg`)
- Cancelled `hm` mid-build to preserve stability
- **Root cause discovered**: `openblas-i686-linux` hangs forever in `checkPhase` on `zblat3` — Ryzen-specific 32-bit test hang
- Temporary fix: `nixpkgs.overlays` with `overrideAttrs (old: { doCheck = false; })` for `openblas` + `liquidctl`
- Overlay later removed from `configuration.nix` (cosmetic, build never completed)
- Someone else posted exact same bug on Discourse 12h ago: `discourse.nixos.org/t/openblas-i686-linux-hangs-in-checkphase-on-zblat3/78487`
- Official nixpkgs issue filed: `github.com/NixOS/nixpkgs/issues/534670`
- **Fix merged**: PR #534770 by Atemu — `doCheck = stdenv.hostPlatform.system != "i686-linux"` on `release-26.05`
- Fix commit `1cf99b9` merged 2026-06-24 at 12:44 UTC; user's `update` at 11:36 AST missed it by ~1h
- Decision: wait for channel to rebuild with fix, then re-run `update`
- **RESOLVED Jun 27**: `nix-channel --update` pulled fix commit `4062d36e`; `nr` rebuilt clean, `hm -b backup` succeeded, `update.fish` removed from funcsave, all functions back to HM-managed symlinks
- Post-reboot: system healthy on new generation, NVIDIA driver loaded, KDE working

### Jun 25 2026 — Post-Blackout Recovery & Cleanup
- Re-ran `update` post-blackout; OpenBLAS x86_64 built and all 30 tests passed (no hang)
- NixOS generation switched successfully; system on latest 26.05
- `hm` cancelled mid-OpenBLAS build (cache cold for some x86_64 packages)
- **`update` alias fixed**: `nix-channel --update && sudo nix-channel --update && sudo nixos-rebuild switch && home-manager switch`
- **`fx` and `nv` converted from aliases to Fish functions** in `fish.nix` (funcsave'd for immediate use)
- **`nv11`, `nvun`, `nv26`, `hc` aliases removed** from `fish.nix`
- **`fs` alias removed** (was added unasked; emergency funcsave pattern kept for manual use)
- **`funcsave` pattern proven**: works as escape hatch when `hm` can't run — alias + funcsave immediately persists aliases without Nix evaluation
- Cleaned up leftover funcsave files on disk (`fs.fish`, `update.fish`)
- Colmena evaluated: overkill for single-machine setup; 6-curl bootstrap stays
- SSD healthy: 860 QVO 1TB, 87% wear, ~95TB written, 3.58yr on, PASSED
- System stable; pending: `hm` full rebuild when binary cache warms

### Jun 29 2026 — NVIDIA 580.173.02 + Cleanup
- **Driver bumped**: `580.159.04` → `580.173.02` via mkDriver (all hashes updated)
- `nr` succeeded after hash update; reboot applied new driver
- `nv` tool redesigned: smart version check — shows `⚠` when new driver available, `✓` when up to date
- All stale `580.159.04` references purged from `README.md`, `nvidia.nix`, `refresh-memory.md`
- README conflict resolved: `pinned driver` → `pinned drivers`
- System at revision `4062d36e`, driver 580.173.02, OpenBLAS fix included, all clean

### Jun 21 2026
- `systemd.timers.fix-downloads-perms` removed (didn't work long-term); back to manual `fx`
- `gt` alias removed
- Lock file warnings suppressed in `chrome`/`code` aliases with `2>/dev/null`
- Fixed root-owned `.raw` file in Downloads via `fx` (chown sircam:users)
- `opencode-sandbox` flake.lock updated (nixpkgs Jun 8 → Jun 16) — cosmetic, `--override-input` bypasses it
- `--override-input nixpkgs nixpkgs` confirmed intentional: keeps Chrome/opencode on absolute latest
- opencode indicator missing in web UI — transient glitch, engine unaffected
- `home.backupFileExtension = "bak"` attempted in `home.nix` — option doesn't exist in standalone HM. Use `hm -b backup` if file conflicts appear

### Oct 29 2026 — Azoth Launcher Flake (Solved)
- Purpose: run Azoth Launcher (New World fan server) on NixOS; used to join the project's **Live playtests**, not for regular play
- Error on Play: `Couldn't start the game: azoth-patcher.exe does not match this launcher.`
- **Fixed**: added `dontStrip = true;` — commit `2a16534` pushed, verified working (root cause in Bugs & Fixes)
- README rewritten with run instructions — commit `9fbfc68`; documents `NIXPKGS_ALLOW_UNFREE=1 nix run github:sircam-html/azoth-launcher --impure`
- **Run locally**: `Azoth` alias (declarative in `fish.nix`)
- **Friend test**: `NIXPKGS_ALLOW_UNFREE=1 nix run github:sircam-html/azoth-launcher --impure` (needs x86_64-linux, flakes, ~2GB, New World install)
- **RESOLVED**: `Azoth` alias folded into `fish.nix` with the working flags (`GDK_BACKEND=x11 … --refresh --no-write-lock-file`); funcsave leftover `~/.config/fish/functions/Azoth.fish` deleted; `hm` applied
- HM puts aliases under `status is-interactive`, so `fish -lc 'type Azoth'` won't find it — check with `fish -ic 'type Azoth'`
- First Play shows `Setting up Proton (first time only)…` — normal, umu creates the Wine prefix; game launched flawlessly after the fix
- **Gateway stays `127.0.0.1:6000` on purpose** (Cristian's decision): neutral default until the devs announce a Live playtest. Official launcher bakes `71.211.172.176:6000`, but do **not** change it now
- **Playtest day**: edit the two `release.env` lines in `flake.nix` (`GATEWAY_HOST` / `GATEWAY_PORT` with the host the devs announce), commit + push, then `Azoth` picks it up via `--refresh` — no reinstall needed
- Upstream `azoth-src` stays pinned in `flake.lock`; updates are deliberate, not automatic (see Key Decisions)
- **Playtest sin editar el flake (PUSHEADO, commit `342bb66`)**: leer `AZOTH_GATEWAY_HOST` / `AZOTH_GATEWAY_PORT` con `builtins.getEnv` (helper `envOr` con fallback `127.0.0.1` / `6000`) y usarlos en el `release.env` del `buildPhase`. Requiere `--impure` (el alias `Azoth` ya lo lleva). Uso el día del test: `set -x AZOTH_GATEWAY_HOST 1.2.3.4`, `set -x AZOTH_GATEWAY_PORT 6000`, luego `Azoth` — sin commits ni reconstruir a mano; el host queda fijado hasta cerrar la terminal (`set -e` para limpiarlo). Probado con `203.0.113.7:7777`: el binario lleva ese host/puerto incrustados y el par launcher/patcher sigue coincidiendo (`f62773fa…`). Sin las variables el build sigue siendo `127.0.0.1:6000` (comprobado por eval del flake remoto)
- **`bu` false-success bug fixed** in `fish.nix`: `backup` ignored `git push`'s exit status and always printed `✓ Configs backed up to GitHub`. Now it checks `git add`/`git commit`/`git push` and, on rejection, says the remote has newer commits and suggests `cd ~/nixos-conf && git pull --rebase && git push`. Applies to both copies (`fish.nix` line 31 and `live-system/fish.nix` after `bu`)

## Key Decisions
- `mkDriver` over `legacy_580` — channel-independent pinning
- User/sudo/autologin stays in `configuration.nix` (not worth extracting)
- Public cloud flakes for Chrome + OpenCode; private local for tracker
- `nv` uses `--override-input` for live data each run; shows only version (no hash noise)
- `git add -A` in `bu` catches `extras/` changes automatically
- Password/credential experiments reverted to original `admin-sandbox-token`
- No "Wanna try it" section in sandbox README
- Dreadmyst sandbox flake tested, game server unreachable, repo deleted and aliases removed
- No auto-update workflow for `azoth-src` — upstream bumps are done manually with Bhu (`nix flake update azoth-src`, review lock diff, build, fix `vendorHash` if needed) so breakage is caught in real time instead of landing on `main`
- Azoth gateway stays `127.0.0.1:6000` by choice — the flake is for **Live playtests** only, so the real gateway host gets swapped in temporarily when the devs announce a test

## Fresh Restore (bootstrap)
```bash
sudo nixos-generate-config
mkdir -p ~/.config/home-manager
sudo curl -o /etc/nixos/nvidia.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/nvidia.nix \
  && sudo curl -o /etc/nixos/configuration.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/configuration.nix \
  && sudo curl -o /etc/nixos/amd-cpu.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/amd-cpu.nix \
  && curl -o ~/.config/home-manager/home.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/home.nix \
  && curl -o ~/.config/home-manager/fish.nix https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/fish.nix \
  && curl -o ~/Documents/refresh-memory.md https://raw.githubusercontent.com/sircam-html/nixos-conf/main/live-system/refresh-memory.md \
  && sudo nixos-rebuild switch && home-manager switch
```

## Bugs & Fixes
### `fx` self-sabotage (Jun 12 2026)
- **Event**: Browser couldn't download files because `/home/sircam/Downloads` had permissions `drw-r--r--` (missing `x` bit, making it untraversable).
- **Root cause**: `fx` alias ran `chmod 755 ~/Downloads/` then immediately `chmod -R 644 ~/Downloads/`, which recursively set the directory itself back to 644. Each `fx` run fixed then broke itself.
- **Solution**: Replaced blanket `chmod -R 644` with `find ~/Downloads -type f -exec chmod 644 + && find ~/Downloads -type d -exec chmod 755 +`. Files stay read-only (safe from accidental delete), directories stay traversable.

### Nix strip breaks the patcher hash (Oct 29 2026)
- **Event**: Azoth Launcher built from the flake refused to start the game: `azoth-patcher.exe does not match this launcher`
- **Root cause**: upstream `scripts/release-linux.sh` builds `azoth-patcher.exe`, computes its sha256, and bakes it into the launcher (`-X main.patcherSHA256`). Nix's `fixupPhase` strip hook (`strip.sh`) strips **every** file in `bin/` with no ELF check, so it rewrote the Windows PE patcher *after* hashing → guaranteed mismatch
- **Proof**: launcher's baked hash `f62773fa…` vs shipped patcher `8db3001f…`; `strip -S -p` alone changed a fresh patcher `37043d0f…` → `f4536b68…`; official v0.2.0 release is self-consistent, confirming the check was fine
- **Fetching the baked hash**: symbols are stripped (nixpkgs defaults to `-s -w`), so parse the ELF string headers directly (a `.data` `{ptr,len}` pair pointing at the 64-byte hex) instead of `nm`/`strings`
- **Solution**: `dontStrip = true;` in the derivation. Rebuild verified both hashes equal `f62773fa…`. Harmless: both Go binaries already use `-s -w`
- **General lesson**: any Nix package that verifies the sha256 of a sibling file will break if the stdenv strip hook rewrites that file — use `dontStrip` (or `stripExclude`)

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
- **REMINDER**: After `hm` runs successfully, delete `~/.config/fish/functions/update.fish` so fish.nix's `update` alias takes effect

