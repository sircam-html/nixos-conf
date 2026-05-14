# NixOS 26.05 Migration Guide
Complete step-by-step guide to migrate from 25.11 to 26.05.

## Step 1 — Check Stability First
Before doing anything, verify critical packages build on 26.05:

```bash
hc bottles --channel 26.05
```
**Only proceed if all results show ✔**
If any show ✖ — wait and check again later!

## Step 2 — Update Channels
Replace both NixOS and Home Manager channels:

```bash
sudo nix-channel --add https://nixos.org/channels/nixos-26.05 nixos
nix-channel --add https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz home-manager
sudo nix-channel --update
```

## Step 3 — Check NVIDIA legacy_580 Availability
On 26.05, `legacy_580` might be available — check first:

```bash
nix eval nixpkgs#linuxPackages.nvidiaPackages.legacy_580 --impure 2>/dev/null && echo "✔ legacy_580 available" || echo "✖ use mkDriver instead"
```

If **available** → update `configuration.nix`:
```nix
package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
```

If **not available** → keep pinned `mkDriver` as is.

## Step 4 — Update configuration.nix
Update the top comment:
```nix
# NixOS 26.05 + NVIDIA driver
```

Update sleep/hibernation if syntax changed:
```nix
# Try this first (26.05+)
systemd.sleep.settings.Sleep = {
  AllowSuspend              = "no";
  AllowHibernation          = "no";
  AllowHybridSleep          = "no";
  AllowSuspendThenHibernate = "no";
};
```

## Step 5 — Check home.nix Packages
Some packages may have changed names or become available:
- `pear-desktop` → check if available, replace `youtube-music` if so
- `bottlesNoWarning` → try adding back if openldap bug is fixed

## Step 6 — Rebuild System
```bash
nr && hm
```

## Step 7 — Verify Everything Works
```bash
ver
nvidia-smi
hc bottles --channel 26.05
```

Check:
- ✅ NixOS version shows 26.05
- ✅ Home Manager shows 26.05
- ✅ NVIDIA driver loaded correctly
- ✅ Bottles builds and launches
- ✅ DDO runs at full FPS 🎮

## Step 8 — Cleanup
```bash
trim
```

## Step 9 — Update README.md
```markdown
| OS | NixOS 26.05 |
```

## Rollback if Something Breaks
If anything goes wrong after migration:
```bash
sudo nixos-rebuild switch --rollback
```
This instantly rolls back to your last working 25.11 generation! 🎉

## Quick Reference
| Command | Description |
|---------|-------------|
| `hc bottles --channel 26.05` | Check Bottles stability before migrating |
| `nr && hm` | Rebuild system and Home Manager |
| `ver` | Verify versions after migration |
| `trim` | Clean up old generations |
| `sudo nixos-rebuild switch --rollback` | Roll back if something breaks |
