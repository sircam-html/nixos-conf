# NixOS Unstable Home Manager configuration
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
    gedit
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
  programs.home-manager.enable  = true;
  programs.google-chrome.enable = true;

  # ── Fastfetch ─────────────────────────────────────────────────────────────────
  # Managed via Home Manager, preset set via ff alias
  programs.fastfetch.enable = true;

  programs.fish = {
    enable = true;
    shellAliases = {
      # Update system and home-manager
      up     = "sudo nix-channel --update && sudo nixos-rebuild switch --upgrade && home-manager switch";
      # Home Manager switch
      hm     = "home-manager switch";
      # NixOS rebuild
      nr     = "sudo nixos-rebuild switch";
      # Edit system config
      cn     = "sudo gedit /etc/nixos/configuration.nix";
      # Edit home config
      hn     = "gedit ~/.config/home-manager/home.nix";
      # Nix garbage collect
      gc     = "sudo nix-collect-garbage -d";
      # Delete old Nix generations and update bootloader
      dg     = "sudo nix-env --delete-generations old && sudo nixos-rebuild boot";
      # Nix store optimise
      op     = "nix store optimise";
      # Restart KDE Plasma shell
      ps     = "systemctl --user restart plasma-plasmashell";
      # Fastfetch with custom preset
      ff     = "fastfetch -c examples/7";
      # Hydra status check
      hc     = "hydra-check";
    };
  };

}

