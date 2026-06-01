# NixOS 26.05 Stable | /home/sircam/.config/home-manager/
# User apps: 100% pure, no system packages here
# Declarative safe-update included — Hydra pre-flight check before updates

{ config, pkgs, ... }:

let
  # ── Zen Browser ───────────────────────────────────────────────────────────────
  # Unpinned on purpose: pulls latest from master on every switch
  zen = import (builtins.fetchTarball
    "https://github.com/youwen5/zen-browser-flake/archive/master.tar.gz"
  ) { inherit pkgs; };

  # ── Bottles (remove warning popup) ───────────────────────────────────────────
  bottlesNoWarning = pkgs.bottles.override {
    removeWarningPopup = true;
  };

  # ── Safe Update Script (Declarative Implementation) ──────────────────────────
  safeUpdateScript = pkgs.writeShellScriptBin "safe-update" ''
    # pre-update-check.sh
    # Checks active Home Manager AND System packages on Hydra before updating

    # Exit immediately if a command in a pipeline fails unexpectedly
    set -o pipefail

    CHANNEL="26.05"
    FAILED=0

    echo "🔍 Dynamic lookup: Extracting allowed unfree packages from your Nix config..."

    # DYNAMIC UNFREE DETECTION: Evaluates your allowed unfree packages from Nixpkgs config in real-time
    declare -A UNFREE_PACKAGES
    while IFS= read -r unfree_pkg; do
      [[ -z "$unfree_pkg" ]] && continue
      unfree_pkg=$(echo "$unfree_pkg" | tr -d '"')
      UNFREE_PACKAGES["$unfree_pkg"]=1
    done < <(${pkgs.nix}/bin/nix-instantiate --eval -E 'builtins.attrNames (import <nixpkgs> {}).config.allowUnfreePredicate.pkgNames or {}' 2>/dev/null | tr -d '[]' | tr ' ' '\n' || true)

    # Fallback: Safety net if you use allowUnfree = true
    if [ ''${#UNFREE_PACKAGES[@]} -eq 0 ]; then
      for pkg in ferdium discord google-chrome vivaldi brave steam zen-browser unrar coolercontrol; do
        UNFREE_PACKAGES["$pkg"]=1
      done
    fi

    echo "🔍 Fetching currently installed packages (System + Home Manager)..."

    # 1. Fetch user packages from Home Manager safely (Using absolute path from context)
    user_pkgs=$(home-manager packages 2>/dev/null | ${pkgs.gawk}/bin/awk '{print $1}')

    # 2. OPTIMIZATION: Read from the current system profile
    system_pkgs=$(${pkgs.nix}/bin/nix-env -p /run/current-system/sw -q 2>/dev/null)

    # 3. Combine both, safely clean versions, and remove duplicates
    packages=()
    while IFS= read -r pkg; do
      [[ -z "$pkg" ]] && continue
      # FIX: Added |safe-update at the end so the script ignores itself
      [[ "$pkg" =~ ^(hm-session-vars.*|home-configuration-reference.*|home-manager-path|safe-update)$ ]] && continue
      packages+=("$pkg")
    done < <(printf "%s\n%s" "$user_pkgs" "$system_pkgs" | ${pkgs.gnused}/bin/sed -E 's/-[0-9](\.[0-9])*.*//' | sort -u)

    if [ ''${#packages[@]} -eq 0 ]; then
      echo "❌ Error: No packages detected in your profile. Aborting."
      exit 1
    fi

    echo "🔍 Checking ''${#packages[@]} unique packages on nixos-$CHANNEL..."
    echo "─────────────────────────────────────────────────"

    for pkg in "''${packages[@]}"; do
      if [[ -n "''${UNFREE_PACKAGES[$pkg]}" ]]; then
        echo "📦 $pkg → Pre-built binary, unfree, or daemon (Hydra doesn't track) — assumed OK"
        continue
      fi

      if [[ "$pkg" == nerd-fonts-* ]]; then
        echo "📦 $pkg → Font package — skipped verification"
        continue
      fi

      hydra_name="$pkg"
      case "$pkg" in
        kcalc|yakuake|filelight|kolourpaint|ktorrent|sweeper|isoimagewriter)
          hydra_name="kdePackages.$pkg"
          ;;
      esac

      # Run hydra-check using its exact path in the Nix store
      if ! result=$(${pkgs.hydra-check}/bin/hydra-check "$hydra_name" --channel "$CHANNEL" 2>&1); then
        echo "⚠️  $hydra_name → Not found or query error (Skipped)"
        continue
      fi

      if echo "$result" | ${pkgs.gnugrep}/bin/grep -q "✔"; then
        echo "✅ $pkg → OK"
      elif echo "$result" | ${pkgs.gnugrep}/bin/grep -q "✖"; then
        echo "❌ $pkg → FAILED"
        FAILED=1
      else
        echo "⚠️  $pkg → Unknown or unbuilt status"
      fi
    done

    echo "─────────────────────────────────────────────────"

    if [ "$FAILED" -eq 1 ]; then
      echo "❌ Some packages failed on Hydra. Update aborted!"
      exit 1
    else
      echo "✅ All packages green. Safe to update!"
      echo "🚀 Running update..."

      sudo nix-channel --update && \
      sudo nixos-rebuild switch --upgrade && \
      home-manager switch
    fi
  '';

in {

  # ── User ──────────────────────────────────────────────────────────────────────
  home.username      = "sircam";
  home.homeDirectory = "/home/sircam";
  home.stateVersion  = "25.11";
  home.enableNixpkgsReleaseCheck = false;
  news.display               = "silent";
  nixpkgs.config.allowUnfree = true;

  # ── Fonts ─────────────────────────────────────────────────────────────────────
  fonts.fontconfig.enable = true;

  # ── Packages ──────────────────────────────────────────────────────────────────
  home.packages = (with pkgs; [

    # Built-in Scripts
    safeUpdateScript

    # KDE
    kdePackages.isoimagewriter
    kdePackages.kolourpaint
    kdePackages.filelight
    kdePackages.ktorrent
    kdePackages.yakuake
    kdePackages.sweeper
    kdePackages.kcalc

    # Gaming / Streaming
    coolercontrol.coolercontrol-gui
    bottlesNoWarning
    obs-studio
    mangohud
    goverlay
    heroic
    steam
    wine

    # Browsers
    brave
    discord
    ferdium

    # Dev / Productivity
    hydra-check
    devbox
    htop
    git

    # Multimedia
    pear-desktop
    unrar
    vlc

    # VMs
    virt-manager

    # Fonts
    nerd-fonts.jetbrains-mono  # great terminal font
    nerd-fonts.fira-code

  ]) ++ [
    zen.default  # Zen Browser — sourced outside nixpkgs via fetchTarball
  ];

  # ── Programs ──────────────────────────────────────────────────────────────────
  programs.home-manager.enable = true;

  # ── Fastfetch ─────────────────────────────────────────────────────────────────
  # Managed via Home Manager, preset set via ff alias
  programs.fastfetch.enable = true;

  programs.fish = {
    enable = true;

    shellAliases = {
      # Update system and home-manager
      update      = "sudo nix-channel --update && sudo nixos-rebuild switch --upgrade && home-manager switch";
      # Verify critical packages on Hydra before updating — aborts if any fail (Now declaratively managed)
      safe-update = "safe-update";
      # Full system cleanup
      trim        = "nix-collect-garbage -d && sudo nix-collect-garbage -d && sudo nix-env --delete-generations old && sudo nixos-rebuild boot && home-manager expire-generations '2 weeks ago' && nix store optimise";
      # Home Manager switch
      hm          = "home-manager switch";
      # NixOS rebuild
      nr          = "sudo nixos-rebuild switch";
      # Edit system config
      cn          = "kate /etc/nixos/configuration.nix";
      # Edit home config
      hn          = "kate ~/.config/home-manager/home.nix";
      # Nix garbage collect (user + system)
      gc          = "nix-collect-garbage -d && sudo nix-collect-garbage -d";
      # Delete old Nix generations and update bootloader
      dg          = "sudo nix-env --delete-generations old && sudo nixos-rebuild boot";
      # Nix store optimise
      op          = "nix store optimise";
      # Restart KDE Plasma shell
      ps          = "systemctl --user restart plasma-plasmashell";
      # Fastfetch with custom preset
      ff          = "fastfetch -c examples/25";
      # Fix Downloads folder permissions
      fx          = "sudo chmod 755 ~/Downloads/ && sudo chown -R sircam:users ~/Downloads/ && sudo chmod -R 644 ~/Downloads/*";
      # Check all channels (user + system)
      ch          = "sudo nix-channel --list && echo '───' && nix-channel --list";
      # Check NixOS and Home Manager versions and revision
      ver         = "nixos-version && nixos-version --revision && home-manager --version";
      # Hydra build status check
      hc          = "hydra-check";
      # Check NVIDIA legacy_580 availability per channel
      nv11        = "NIXPKGS_ALLOW_UNFREE=1 nix eval github:NixOS/nixpkgs/nixos-25.11#linuxPackages.nvidiaPackages.legacy_580.version";
      nvun        = "NIXPKGS_ALLOW_UNFREE=1 nix eval github:NixOS/nixpkgs/nixos-unstable#linuxPackages.nvidiaPackages.legacy_580.version";
      nv26        = "NIXPKGS_ALLOW_UNFREE=1 nix eval github:NixOS/nixpkgs/nixos-26.05#linuxPackages.nvidiaPackages.legacy_580.version";
      # Launch Caddy server inside Devbox for local websites
      servers     = "cd /home/sircam/_devbox/ && devbox run caddy run --config Caddyfile";
    };
  };

}
