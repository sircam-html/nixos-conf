# Moving NixOS and Home Manager to Unstable

This document outlines the steps taken to successfully transition the NixOS system and Home Manager configuration from the stable release channel to the bleeding-edge `unstable` development branch.

## Current System Status
* **OS Version:** `26.11-pre` (Zokor)
* **Channel Tracked:** Absolute latest development branch (pre-release)

---

## Migration Guide

### 1. Update the System (Root) Channels
The system-wide channels must point to the specific repository release URLs. Root domain shortcuts will cause HTTP 404 download errors. Run these commands with `sudo` privileges:

```bash
# Overwrite the system channel to point to nixos-unstable
sudo nix-channel --add https://nixos.org nixos

# Overwrite the system home-manager channel to point to the correct tarball archive
sudo nix-channel --add https://github.com home-manager
```

### 2. Update the User Channel
To prevent user profile configuration mismatches, ensure your local user account tracks the exact same master branch for Home Manager:

```bash
nix-channel --add https://github.com home-manager
```

### 3. Verify Channel Layout
Before building, verify that the URLs are fully qualified. Using generic root domains (`https://nixos.org` or `https://github.com`) will break the Nix build toolchain.

* Check system channels: `sudo nix-channel --list`
* Check user channels: `nix-channel --list`

**Expected Output Alignment:**
* `nixos` -> `https://nixos.org`
* `home-manager` -> `https://github.com`

### 4. Fetch Packages and Apply Changes
Fetch the new package definitions separately, then rebuild both the system and user environments:

```bash
# Pull down the latest package expressions for root and user
sudo nix-channel --update
nix-channel --update

# Switch the operating system to unstable
sudo nixos-rebuild switch

# Switch the user environment to unstable
home-manager switch
```

---

## Post-Migration Verification
To confirm that the migration was successful, verify the active system version string:

```bash
nixos-version
```
*Successful Output:* Should contain `26.11-preXXXXXXX (Zokor)`. The `pre` indicator confirms that your environment is actively tracking the unstable development track.
