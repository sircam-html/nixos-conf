# NixOS Unstable / Home Manager configuration
# User apps: 100% pure, no system packages here

{ config, pkgs, ... }:

let
  # ── Zen Browser ───────────────────────────────────────────────────────────────
  # Unpinned on purpose: pulls latest from master on every switch
  zen = import (builtins.fetchTarball
    "https://github.com/youwen5/zen-browser-flake/archive/master.tar.gz"
  ) { inherit pkgs; };

in {

  # ── User ──────────────────────────────────────────────────────────────────────
  home.username      = "sircam";
  home.homeDirectory = "/home/sircam";
  home.stateVersion  = "25.11";
  home.enableNixpkgsReleaseCheck = false;
  news.display               = "silent";
  nixpkgs.config.allowUnfree = true;

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
    kdePackages.kate

    # Gaming / Streaming
    coolercontrol.coolercontrol-gui
    obs-studio
    mangohud
    goverlay
    heroic
    steam
    wine

    # Browsers
    chromium
    ferdium
    discord

    # Dev / Productivity
    hydra-check
    devbox
    htop
    git

    # Multimedia
    pear-desktop  # YouTube Music desktop client
    stellarium
    unrar
    vlc

    # VMs
    virt-manager

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
      update = "sudo nix-channel --update && sudo nixos-rebuild switch --upgrade && home-manager switch";
      # Full system cleanup
      trim   = "sudo nix-collect-garbage -d && sudo nix-env --delete-generations old && sudo nixos-rebuild boot && home-manager expire-generations '2 weeks ago' && nix store optimise";
      # Home Manager switch
      hm     = "home-manager switch";
      # NixOS rebuild
      nr     = "sudo nixos-rebuild switch";
      # Edit system config
      cn     = "kate /etc/nixos/configuration.nix";
      # Edit home config
      hn     = "kate ~/.config/home-manager/home.nix";
      # Nix garbage collect
      gc     = "sudo nix-collect-garbage -d";
      # Delete old Nix generations and update bootloader
      dg     = "sudo nix-env --delete-generations old && sudo nixos-rebuild boot";
      # Nix store optimise
      op     = "nix store optimise";
      # Restart KDE Plasma shell
      ps     = "systemctl --user restart plasma-plasmashell";
      # Fastfetch with custom preset
      ff     = "fastfetch -c examples/25";
      # Hydra status check
      hc     = "hydra-check";
    };
  };

}
