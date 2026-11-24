# Bhu's Refresh Memory — NixOS & Guix System State
## You may also be summoned inside Guix (VM) from NixOS
## To restore Bhu's context, say: "Bhu, read refresh-memory"
## If summoned inside Guix VM, say: "Bhu, read guix-memory"
## (Call me Cristian)

## Goal
Declarative, modular NixOS 26.05 with NVIDIA **production driver + open kernel modules** for the **RTX 3070 (Ampere)**. Reproducible via GitHub backups (HTTPS, no SSH), deployable on fresh machines with 5 curls.

## Constraints
- NixOS 26.05 stable, KDE Plasma 6, Wayland, AMD CPU + NVIDIA RTX 3070 (Ampere, open kernel modules)
- Fish shell; all user config in Home Manager
- `nixpkgs.config.allowUnfree = true`
- Ephemeral flakes for Chrome, opencode, safe-update (scoped `allowUnfreePredicate`)
- Backup via `bu` alias (Fish function) — HTTPS + curl, no SSH keys

## Repos
- **NixOS**: `github:sircam-html/nixos-conf` (public) — `live-system/`, `extras/`, `tracker/`
- **Guix**: `codeberg.org/SIRCAM/Guix_configuration` — `live-system/`, `extra/` (Nix-in-Guix hybrid)
- **Azoth Launcher**: `github:sircam-html/azoth-launcher` (public) — flake running the **official 1.0.x Windows build under Wine** (see Nov 10 2026); the old Wails/WebKitGTK native build from `github:KyzaBOY/azoth-launcher` is retired (upstream source stopped at v0.2.0)
- **UT4 Launcher**: `github:sircam-html/utx-launcher` (public) — flake wrapping the **UT4 Community Launcher (NetcodePlus) 1.9.0 AppImage** with bundled Wine Staging, DXVK and Vulkan (see Nov 23 2026)

## Config Files & Imports
- `/etc/nixos/configuration.nix` — imports: `./hardware-configuration.nix`, `./nvidia.nix`, `./amd-cpu.nix`
- `/etc/nixos/nvidia.nix` — NVIDIA module for RTX 3070: `hardware.graphics.enable`/`enable32Bit`, `hardware.nvidia.modesetting.enable = true` (Wayland/KDE), `open = true` (Ampere supports open modules), `package = config.boot.kernelPackages.nvidiaPackages.production`, `nvidiaSettings = true`, `powerManagement.enable = false` (suspend disabled). Session vars: `LIBVA_DRIVER_NAME=nvidia`, `NIXOS_OZONE_WL=1`
- `/etc/nixos/amd-cpu.nix` — AMD CPU: `amd_pstate=passive`, microcode, TLP, power-profiles-daemon off, no sleep/hibernation
- `~/.config/home-manager/home.nix` — imports `./fish.nix`
- `~/.config/home-manager/fish.nix` — all aliases + backup function
- `~/.config/home-manager/nvidia.nix` — **deleted**, no import references

## Key Aliases
- `bu` → backup 6 configs + refresh-memory.md to GitHub
- `nv` → live NVIDIA tracker with version/update box (stderr suppressed)
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
- `Azoth` → run Azoth Launcher ephemeral: `env GDK_BACKEND=x11 NIXPKGS_ALLOW_UNFREE=1 nix run github:sircam-html/azoth-launcher --impure --refresh --no-write-lock-file` (flags harmless but unnecessary since Nov 10; plain `nix run` is enough now)

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
- **`hc` alias removed** from `fish.nix`
- **`fs` alias removed** (was added unasked; emergency funcsave pattern kept for manual use)
- **`funcsave` pattern proven**: works as escape hatch when `hm` can't run — alias + funcsave immediately persists aliases without Nix evaluation
- Cleaned up leftover funcsave files on disk (`fs.fish`, `update.fish`)
- Colmena evaluated: overkill for single-machine setup; 6-curl bootstrap stays
- SSD healthy: 860 QVO 1TB, 87% wear, ~95TB written, 3.58yr on, PASSED
- System stable; pending: `hm` full rebuild when binary cache warms

### Jun 29 2026 — Cleanup
- `nv` tool redesigned: smart version check — shows `⚠` when a new driver is available, `✓` when up to date
- System at revision `4062d36e`, OpenBLAS fix included, all clean

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
- **Playtest day**: edit the two `release.env` lines in `flake.nix` (`GATEWAY_HOST` / `GATEWAY_PORT` with the host the devs announce), commit + push, then `Azoth` picks it up via `--refresh` — no reinstall needed *(obsolete since Nov 10 2026 — the official build bakes its own gateway)*
- Upstream `azoth-src` stays pinned in `flake.lock`; updates are deliberate, not automatic (see Key Decisions)
- **Playtest sin editar el flake (PUSHEADO, commit `342bb66`)**: leer `AZOTH_GATEWAY_HOST` / `AZOTH_GATEWAY_PORT` con `builtins.getEnv` (helper `envOr` con fallback `127.0.0.1` / `6000`) y usarlos en el `release.env` del `buildPhase`. *(Obsoleto desde Nov 10 2026: el flake ya no compila el source, corre el exe oficial de Windows bajo Wine.)* Requiere `--impure` (el alias `Azoth` ya lo lleva). Uso el día del test: `set -x AZOTH_GATEWAY_HOST 1.2.3.4`, `set -x AZOTH_GATEWAY_PORT 6000`, luego `Azoth` — sin commits ni reconstruir a mano; el host queda fijado hasta cerrar la terminal (`set -e` para limpiarlo). Probado con `203.0.113.7:7777`: el binario lleva ese host/puerto incrustados y el par launcher/patcher sigue coincidiendo (`f62773fa…`). Sin las variables el build sigue siendo `127.0.0.1:6000` (comprobado por eval del flake remoto)
- **`bu` false-success bug fixed** in `fish.nix`: `backup` ignored `git push`'s exit status and always printed `✓ Configs backed up to GitHub`. Now it checks `git add`/`git commit`/`git push` and, on rejection, says the remote has newer commits and suggests `cd ~/nixos-conf && git pull --rebase && git push`. Applies to both copies (`fish.nix` line 31 and `live-system/fish.nix` after `bu`)

### Oct 29 2026 — Fresh Install Validated in VM + README Fix
- Cristian tested the full quick install in a **virt-manager VM**; system installed and booted fine
- **VM setup gotchas**: `systemd-boot` needs UEFI/OVMF firmware; `./nvidia.nix` must be commented out of `imports` (no NVIDIA GPU in a VM → Xorg won't start)
- **Only real failure**: the README block's last step `&& home-manager switch` → `command not found`. Root cause: `configuration.nix` does not enable Home Manager as a NixOS module, so the CLI does not exist on a clean install. He installed it manually with the three channel/`nix-shell` commands and everything worked — **diagnosis confirmed by the test**, not just by reading files
- **README fixed** (commit `7e68294`, pushed): the copy block now ends at `sudo nixos-rebuild switch`; new section **"Home Manager (first time only)"** with the three commands + `home-manager switch` + a `master` note
- VM used `master` → Home Manager reports **26.11-pre** (dev branch for the next release). His PC stays on `release-26.05` → `26.05-pre`; nothing changed on his system
- Deliberately **not** applied (robustness only, not blockers): `curl -fL` (a 404 currently writes an error page into a `.nix` file) and `mkdir -p ~/Documents` (missing dir aborts the `&&` chain before the rebuild). Do not add them unless he asks

### Nov 1 2026 — OpenCode Token Tuning
- `~/.config/opencode/opencode.json` still had V1-era compaction fields `prune` and `reserved: 16000`, which **do nothing in OpenCode V2**
- Replaced with the V2 shape: `keep: { tokens: 8000 }` + `buffer: "20%"` → compacts at 80% of the window and keeps less recent detail
- **Why**: checked usage first (`opencode stats --cost --days 30`) → **$0.00** / 30 days, and `opencode/big-pickle` costs $0 per token. Model choice saves nothing here; the real limit is tokens against the free quota, so the file is the only lever that cuts actual consumption
- Config hot-reloads on save — no restart needed
- If long sessions start forgetting details too early, raise `keep.tokens` to `12000`
- Note: `opencode` is **not on PATH**; the CLI lives in the nix store (`/nix/store/*-opencode-2.2.1/bin/opencode`). Path changes on rebuild, so don't hardcode it in scripts
- Deliberately **not** done: a global `~/.config/opencode/AGENTS.md` with brevity rules (helps, but it's behavior, not tuning) — add only if Cristian asks

### Nov 10 2026 — Azoth 1.0.29: official Windows build under Wine
- Upstream moved: 1.0.x releases live in `KyzaBOY/azoth-launcher-releases` (installers only, **no source**), and they are **Electron Windows apps**. The source repo `KyzaBOY/azoth-launcher` is stale at v0.2.0 (Oct 22) and there is **no Linux build and no 1.0.29 source anywhere public** — checked tags, branches, Actions runs, and `latest-linux.yml` (404)
- So the old flake had nothing to update to: bumping `azoth-src` would have rebuilt the same October code
- **New approach — run the official Windows payload under Wine, ephemerally via `nix run`**
  - `fetchurl` the official exe (sha256 pinned); `p7zip` unpacks the NSIS payload `$PLUGINSDIR/app-64.7z` at build time (the installer itself is never run — silent install fails)
  - runs with `wineWow64Packages.stable`: **his profile wine is 32-bit only → "Bad EXE format"**; wow64 is required for the 64-bit Electron app
  - flags `--no-sandbox --disable-gpu`; `WINEDLLOVERRIDES="mscoree,mshtml="`; own prefix at `~/.local/share/azoth-launcher-wine`
  - app is copied into the prefix (writable) so the launcher's own updater can write; `.version` marker re-copies when the version changes
  - `steam-run`, umu-launcher, WebKitGTK and the Go/Wails build are all gone from the closure
- **Verified**: built and launched 1.0.29 locally (window opened and stayed up), then killed and cleaned up; Cristian also confirmed it works **from GitHub** with `nix run github:sircam-html/azoth-launcher`
- **Future bumps**: change `version` and the hash — `nix hash convert --to sri sha256 <exe>` (or just copy the correct hash Nix prints on mismatch). Only moving part: upstream changing the installer format
- **Anyone with Nix + flakes** can `nix run github:sircam-html/azoth-launcher`; Wine comes from the flake, nothing installed; x86_64-linux only; commit `flake.lock` so everyone gets the same Wine
- **Caveat**: the game now starts inside that Wine prefix, not through umu/Proton like the native build — validate on playtest day
- Supersedes the Oct 29 `builtins.getEnv` gateway trick and the `AZOTH_GATEWAY_HOST/PORT` instructions: the official build bakes its own gateway, so no env override exists anymore

### Nov 23 2026 — UT4 Community Launcher flake (performance fixed)
- Repo `github:sircam-html/utx-launcher`, public. Files pushed: `flake.nix`, `flake.lock`, `README.md` (commit `f03ebf4` verified from GitHub raw). The local working copy `~/Downloads/utx-launcher-main` was deleted afterwards; GitHub is now the only source.
- Run: `nix run --refresh github:sircam-html/utx-launcher` (use `--refresh` after a push, otherwise Nix reuses the cached revision); plain `nix run github:sircam-html/utx-launcher` once cached.
- Wraps the v1.9.0 AppImage with `appimageTools.wrapType2` (bwrap/FHS env). Bundles `wineWow64Packages.staging`, `dxvk`, `vulkan-loader`, `vulkan-tools`, WebKitGTK/GTK for the Tauri UI.
- First-time setup inside the launcher: Wine runner dir → `~/.local/share/ut4-wine-runner`; UT4 install → `~/Documents/LocalGames/UnrealTournament/UnrealTournament`; prefix → `~/.local/share/ut4-wine-prefix`. Deleting `~/.config/org.netcodeplus.launcher` resets those settings.
- **Root cause of the slowness + fix** (see Bugs & Fixes): on first launch the wrapper now copies real DXVK DLLs into the prefix (x64 → `drive_c/windows/system32`, x86 → `SysWOW64`), guarded by marker `.nix-dxvk-installed`; originals saved as `*.bak`. It also exports `WINEDLLOVERRIDES=d3d11,d3d10core,dxgi,d3d9=n,b`, `__GLX_VENDOR_LIBRARY_NAME=nvidia`, `VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json`, `WINEFSYNC=1`, `WINEDEBUG=-all`. Every value uses `${VAR:-default}`, so the shell can override it.
- **Verified**: `vulkaninfo` inside the wrapper went from `NVIDIA GeForce RTX 3070` + **2× llvmpipe** to **only** NVIDIA; prefix `d3d11.dll` went from Wine builtin 1,096,436 bytes to real DXVK 11,533,971 bytes. Cristian confirmed normal game speed afterwards.
- Clean-state test: removed `~/.config/org.netcodeplus.launcher`, `~/.local/share/ut4-wine-prefix`, `~/.local/share/ut4-wine-runner`, then ran from GitHub with `DXVK_HUD=devinfo,fps nix run --refresh ...` so the first-run path is exercised from zero.
- HUD check: overlay must show the NVIDIA GPU, never `llvmpipe`. README documents an AMD override example (`radeon_icd.x86_64.json` + `__GLX_VENDOR_LIBRARY_NAME=mesa`) and the `--refresh` tip.
- **Desktop entry**: `~/.local/share/applications/ut4-community-launcher.desktop` — same pattern as the Azoth one, `Exec=/run/current-system/sw/bin/bash -c 'exec /run/current-system/sw/bin/nix run github:sircam-html/utx-launcher >/dev/null 2>&1'`, `StartupWMClass=netcodeplus-launcher`. Icon copied from the extracted AppImage to `~/Pictures/Icons/ut4-launcher.png` so `nix gc` cannot break it. Log-out/in needed to pick it up (no `update-desktop-database` on this system).
- **Safety**: no hardware/driver/system changes — only process env vars and files inside the user's Wine prefix. Fully reversible: delete the prefix (or just `.nix-dxvk-installed` + restore `*.bak`) or revert the flake. If a launch fails, change `>/dev/null 2>&1` in the desktop entry to `>/tmp/ut4-launcher.log 2>&1` to see errors.
- **Hardware (Nov 23)**: this host reports `NVIDIA GeForce RTX 3070` (PCI `0x10de:0x2484`), driver `595.71.05`. `/etc/nixos/nvidia.nix` uses the **production** package with `open = true`. The UT4 flake uses the generic `/run/opengl-driver/...` ICD path, so it follows whatever driver is enabled.

### Nov 23 2026 — `bu` push auth after fresh NixOS install
- **Event**: `bu` cloned a new `~/nixos-conf`, committed fine (`e9e3b8a`), but `git push` failed: `Invalid username or token. Password authentication is not supported for Git operations.` plus `ksshaskpass`/QtKeychain warnings.
- **Root cause**: the fresh NixOS install wiped the machine-local GitHub login. `~/.gitconfig` had only name/email, no `~/.git-credentials`, no `credential.helper`; nothing in the NixOS/Home Manager config ever stored it. GitHub HTTPS no longer accepts passwords — a token is required.
- **Fix (one-time, token never in chat or repo)**: fine-grained PAT for repo `nixos-conf`, permission **Contents: Read and write**. In fish:
  ```fish
  read -s -P 'GitHub token: ' TOKEN
  printf 'https://sircam-html:%s@github.com\n' $TOKEN > ~/.git-credentials
  set -e TOKEN
  chmod 600 ~/.git-credentials
  git config --global credential.helper store
  cd ~/nixos-conf && git push
  ```
- Local commit was safe — only the push failed; no need to re-clone or redo work. After the token is stored, `bu` is silent again.
- **Misleading message**: `bu` prints "remote has newer commits — run git pull --rebase" for *any* push failure; it doesn't inspect the real error. If it appears, run plain `git push` first to see the actual cause.
- **Decision**: do **not** add the credential helper declaratively to `home.nix` (Cristian declined); the token file stays local only.

## Key Decisions
- **NVIDIA = production package + open kernel modules** (`hardware.nvidia.open = true`): the RTX 3070 is Ampere, so open modules are supported. Driver version follows `config.boot.kernelPackages.nvidiaPackages.production`; no manual hash pinning to maintain
- `hardware.nvidia.modesetting.enable = true` is required for KDE Wayland; `powerManagement.enable = false` because suspend/hibernate is disabled in `amd-cpu.nix`
- `nv` tracks the live driver version from nixpkgs (unstable/stable) via `--override-input`; no hardcoded patch target to bump by hand
- User/sudo/autologin stays in `configuration.nix` (not worth extracting)
- Public cloud flakes for Chrome + OpenCode; private local for tracker
- `nv` uses `--override-input` for live data each run; shows only version (no hash noise)
- `git add -A` in `bu` catches `extras/` changes automatically
- Password/credential experiments reverted to original `admin-sandbox-token`
- No "Wanna try it" section in sandbox README
- Dreadmyst sandbox flake tested, game server unreachable, repo deleted and aliases removed
- No auto-update workflow for `azoth-src` — upstream bumps are done manually with Bhu (`nix flake update azoth-src`, review lock diff, build, fix `vendorHash` if needed) so breakage is caught in real time instead of landing on `main` — **retired Nov 10 2026**: the flake no longer builds `azoth-src`, it runs the official Windows exe under Wine
- Azoth gateway stays `127.0.0.1:6000` by choice — the flake is for **Live playtests** only, so the real gateway host gets swapped in temporarily when the devs announce a test — **obsolete since Nov 10 2026**: the official 1.0.x build bakes the real gateway itself
- **UT4 flake is ephemeral** like Azoth: nothing installed system-wide; all state lives in `~/.local/share/ut4-wine-*` and `~/.config/org.netcodeplus.launcher`. GPU pinning is env-only inside the wrapper, never a driver/system change. For non-NVIDIA GPUs override `VK_ICD_FILENAMES` + `__GLX_VENDOR_LIBRARY_NAME` instead of editing the flake
- **Explain one thing at a time.** Cristian (53) says he doesn't process Nix details fast; long technical dumps confuse him. No hashes, store paths or drv comparisons unless they change a decision. He prefers plain "what it does / why it matters" and asking "más simple" if needed
- **He validates before trusting**: testing in a VM caught the `home-manager` gap that reading the files only predicted. Prefer "let's test it" over long theoretical analysis, and change things only when he explicitly asks

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
  && sudo nixos-rebuild switch

# Home Manager — first time only: configuration.nix does NOT install it,
# so `home-manager switch` fails with "command not found" on a clean system.
nix-channel --add https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
home-manager switch
```

- Same block is in `live-system/README.md` (commit `7e68294`), which stops at `nixos-rebuild` and documents the Home Manager step separately
- `release-26.05` = stable, matches NixOS 26.05 and his PC (`26.05-pre`). `master` also works but reports the next release (`26.11-pre`) and drifts on every `nix-channel --update`

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

### UT4 ran extremely slow under Wine (Nov 23 2026)
- **Event**: launcher opened fine and UT4 played, but at a crawl.
- **Root cause 1 — DXVK was enabled but never installed**: the launcher generates a Lutris-style config with `WINEDLLOVERRIDES=d3d11,d3d10core,dxgi,d3d9=n,b` (i.e. "use native DXVK DLLs"), but the AppImage ships no DXVK DLLs and the setup never installed them. The prefix only had Wine's builtins (e.g. `d3d11.dll` = 1,096,436 bytes), so D3D11 went through wined3d/OpenGL.
- **Root cause 2 — software GPU in the sandbox**: `appimageTools.wrapType2` runs in a bwrap/FHS env whose `/etc/profile` adds `/run/opengl-driver/share` to `XDG_DATA_DIRS`. `vulkaninfo` inside the wrapper listed the RTX 3070 **plus two Mesa `llvmpipe` devices** (one from the flake's `mesa` in `extraPkgs`, one from `/run/opengl-driver`), and libglvnd could select Mesa's `libGLX_mesa.so` instead of NVIDIA's.
- **Proof**: `APPIMAGE_DEBUG_EXEC=vulkaninfo <wrapper>` (a built-in nixpkgs appimage hook) showed the device list before/after; DLL byte sizes confirmed builtin vs real DXVK.
- **Solution**: install DXVK DLLs into the prefix once on wrapper startup (marker + `.bak` backups), set `WINEDLLOVERRIDES`, pin `__GLX_VENDOR_LIBRARY_NAME=nvidia` and `VK_ICD_FILENAMES=.../nvidia_icd.json`, enable `WINEFSYNC`. Verified only the NVIDIA GPU remains visible and Cristian reported normal speed.
- **General lesson**: for Wine games in `wrapType2`/bwrap, check *both* that the DXVK DLLs are physically in the prefix **and** which Vulkan ICDs/GLX vendor the sandbox exposes — "DXVK is in extraPkgs" does not mean DXVK is active.

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
- `nv` output: clean box with `=`, live production driver version only (no hashes)
- `nv` boxes are a snapshot of nixpkgs unstable/stable at run time; the driver version simply follows the channel
- `code-wipe && code-kill` before clean OpenCode tests
- Session is isolated per login — shared credentials don't share chats
- `ssd` → full health report; current: Wear 87%, 3.5yr on, ~88TB written, PASSED
- **Azoth bump**: change `version` + hash in the flake, then `nix run ~/Downloads`; app state lives in `~/.local/share/azoth-launcher-wine` (delete it to start clean)
- **Azoth on any NixOS**: `nix run github:sircam-html/azoth-launcher` — Wine comes from the flake, nothing installed (needs flakes, x86_64-linux only)
- Azoth 1.0.x is a Windows-only Electron app: no Linux build upstream, so the flake runs the Windows exe under Wine
- **REMINDER**: After `hm` runs successfully, delete `~/.config/fish/functions/update.fish` so fish.nix's `update` alias takes effect
- **UT4**: `nix run --refresh github:sircam-html/utx-launcher` — AppImage launcher; first run installs DXVK into `~/.local/share/ut4-wine-prefix` and pins the NVIDIA ICD; `--refresh` only needed after a push
- **UT4 speed check**: `DXVK_HUD=devinfo,fps nix run --refresh github:sircam-html/utx-launcher` → overlay must say NVIDIA, never `llvmpipe`
- **UT4 clean slate**: delete `~/.config/org.netcodeplus.launcher` + `~/.local/share/ut4-wine-{prefix,runner}`, then run from GitHub (first-run setup returns)
- **UT4 desktop icon**: `~/Pictures/Icons/ut4-launcher.png` (copied from AppImage, safe from `nix gc`); launcher entry in `~/.local/share/applications/ut4-community-launcher.desktop`
- **`bu` push fails?**: don't trust "remote has newer commits" — run plain `git push` to see the real error. After a fresh install, a PAT must be stored once with `credential.helper store` (see Nov 23 2026)

