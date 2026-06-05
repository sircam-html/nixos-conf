# NixOS Stable 26.05-pre | /home/sircam/.config/home-manager/

{ config, pkgs, ... }:

let
  # ── Zen Browser ───────────────────────────────────────────────────────────────
  zen = import (builtins.fetchTarball
    "https://github.com/youwen5/zen-browser-flake/archive/master.tar.gz"
  ) { inherit pkgs; };

  # ── Bottles (remove warning popup) ───────────────────────────────────────────
  bottlesNoWarning = pkgs.bottles.override {
    removeWarningPopup = true;
  };

in {

  imports = [
    ./fish.nix
  ];

  # ── User ──────────────────────────────────────────────────────────────────────
  home.username                  = "sircam";
  home.homeDirectory             = "/home/sircam";
  home.stateVersion              = "25.11";
  home.enableNixpkgsReleaseCheck = false;
  news.display                   = "silent";
  nixpkgs.config.allowUnfree     = true;

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
    discord
    ferdium

    # Dev / Productivity
    hydra-check
    devbox
    htop
    tmux
    git

    # Multimedia
    pear-desktop
    unrar
    vlc

    # VMs
    virt-manager

    # Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code

  ]) ++ [
    zen.default
  ];

  # ── Programs ──────────────────────────────────────────────────────────────────
  programs.home-manager.enable = true;

  # ── Fastfetch ─────────────────────────────────────────────────────────────────
  programs.fastfetch.enable = true;
}
