# NixOS Home Manager configuration
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
    fastfetch
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

  programs.fish = {
    enable = true;
    shellAliases = {
      # Update system, home-manager and flatpak apps
      update = "sudo nix-channel --update && sudo nixos-rebuild switch --upgrade && home-manager switch && flatpak update -y";
      # Launch Dragon's Dogma Online via Bottles
      ddo    = "flatpak run com.usebottles.bottles";
    };
  };

}
