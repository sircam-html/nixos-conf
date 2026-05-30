# NixOS 26.05 Migration Guide
Complete step-by-step guide to migrate from 25.11 to 26.05.

## ⚠️ Important Notes Before Starting

- Always use `sudo nix-channel` for **both** nixos and home-manager system channels
- Using `nix-channel` without `sudo` only updates user channels, not system channels
- This caused a subtle 25.11/26.05 mismatch — always verify with `sudo nix-channel --list`

## Step 1 — Check Stability First

Before doing anything, verify critical packages build on 26.05:

```bash
safe-update  # runs pre-flight check automatically
```

Or manually:

```bash
hc bottles --channel 26.05
hc openldap --channel 26.05
hc kdePackages.plasma-desktop --channel 26.05
hc brave --channel 26.05
hc pear-desktop --channel 26.05
hc linux --channel 26.05
```

**Only proceed if all results show ✔**
If any show ✖ — wait and check again later!

## Step 2 — Update ALL Channels (use sudo for both!)

```bash
sudo nix-channel --add https://nixos.org/channels/nixos-26.05 nixos
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz home-manager
sudo nix-channel --update
```

⚠️ **Critical:** Use `sudo` for both channels — forgetting it on home-manager leaves system on old version!

## Step 3 — Verify Channels Updated Correctly

```bash
sudo nix-channel --list
nix-channel --list
```

Both should show `26.05` for nixos and home-manager. If any still shows `25.11` re-run Step 2!

## Step 4 — Check NVIDIA legacy_580 Availability

On 26.05, `legacy_580` might be available — check first:

```bash
nv26
```

- If available → switch to `legacy_580` in `configuration.nix`
- If not available → keep pinned `mkDriver` as is

## Step 5 — Update configuration.nix

Update the top comment:
```nix
# NixOS 26.05 + NVIDIA driver pinned to 580.142
```

Update sleep/hibernation syntax (changed in 26.05):
```nix
systemd.sleep.settings.Sleep = {
  AllowSuspend              = "no";
  AllowHibernation          = "no";
  AllowHybridSleep          = "no";
  AllowSuspendThenHibernate = "no";
};
```

## Step 6 — Update home.nix

Update the top comment:
```nix
# NixOS 26.05 Stable / Home Manager configuration
```

Check if previously unavailable packages are now available:
- `pear-desktop` → available on 26.05 ✅ replace `youtube-music`
- `bottlesNoWarning` → available on 26.05 ✅ no overlay needed

Remove openldap overlay if present — not needed on 26.05!

Update `stateVersion`:
```nix
home.stateVersion = "26.05";
```

Update `safe-update.sh` channel variable:
```bash
CHANNEL="26.05"
```

## Step 7 — Rebuild System

```bash
nr && hm
```

## Step 8 — Verify Everything Works

```bash
ver
nvidia-smi
hc bottles --channel 26.05
```

Check:
- ✅ NixOS version shows 26.05
- ✅ Home Manager shows 26.05-pre
- ✅ NVIDIA driver loaded correctly
- ✅ Bottles builds and launches
- ✅ DDO runs at full FPS 🎮

## Step 9 — Update home-manager channel for user too

```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz home-manager
nix-channel --update
hm
```

## Step 10 — Cleanup

```bash
trim
```

## Step 11 — Update README.md

```markdown
| OS | NixOS 26.05 |
```

## Rollback if Something Breaks

```bash
sudo nixos-rebuild switch --rollback
```

## Quick Reference

| Command | Description |
|---------|-------------|
| `safe-update` | Check Hydra then update safely |
| `hc bottles --channel 26.05` | Check Bottles stability |
| `nv26` | Check NVIDIA legacy_580 on 26.05 |
| `nr && hm` | Rebuild system and Home Manager |
| `ver` | Verify versions after migration |
| `trim` | Clean up old generations |
| `sudo nixos-rebuild switch --rollback` | Roll back if something breaks |
