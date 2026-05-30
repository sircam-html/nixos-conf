# Moving NixOS and Home Manager to Unstable

This document outlines the steps taken to successfully transition the NixOS system and Home Manager configuration from the stable release channel to the bleeding-edge `unstable` development branch.

## Current System Status
* **OS Version:** `26.05pre` (Yarara)
* **Channel Tracked:** Absolute latest development branch (pre-release)

---

## Migration Guide

### 1. Update the System (Root) Channels
The system-wide channels must point to the correct unstable repositories. Run these commands with `sudo` privileges:

```bash
# Overwrite the system channel to point to nixos-unstable
sudo nix-channel --add https://nixos.org nixos

# Overwrite the system home-manager channel to point to the master branch
sudo nix-channel --add https://github.com home-manager
```

### 2. Update the User Channel
To prevent configuration mismatches, ensure your local user account also tracks the latest master branch for Home Manager:

```bash
nix-channel --add https://github.com home-manager
```

### 3. Verify Channel Layout
Before building, verify that the URLs are correctly set without missing paths or typos.

* Check system channels: `sudo nix-channel --list`
* Check user channels: `nix-channel --list`

**Expected Output Alignment:**
* `nixos` -> `https://nixos.org`
* `home-manager` -> `https://github.com`

### 4. Fetch Packages and Apply Changes
Once the channels are verified, fetch the new package definitions and rebuild both environments:

```bash
# Pull down the latest package expressions
sudo nix-channel --update
nix-channel --update

# Switch the operating system to unstable
sudo nixos-rebuild switch

# Switch the user environment to unstable
home-manager switch
```

---

## Post-Migration Verification
To confirm that the migration was successful, verify the active system version:

```bash
nixos-version
```
*Successful Output:* Should contain `26.05preXXXXXXX (Yarara)`. The `pre` indicator confirms the active status on the unstable development track.
