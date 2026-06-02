# NixOS 26.05 Stable | /home/sircam/.config/home-manager/

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

     # NEW: Native Fish function that captures your text and pushes automatically
    functions = {
      lazy-push = ''
        git add .
        git commit -m "$argv"
        git push origin main
      '';
    };

    shellAliases = {
      # Method 1: The standard internet execution (Perfect for testing download speeds)
      safe-update-net = "nix run github:sircam-html/safe-update-nix --refresh";
      # Method 2: The hyper-localized execution (Bypasses downloads, instantly evaluates via system cache)
      safe-update     = "nix run github:sircam-html/safe-update-nix --override-input nixpkgs nixpkgs";
      # Update system and home-manager
      update      = "sudo nix-channel --update && sudo nixos-rebuild switch --upgrade && home-manager switch";
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
