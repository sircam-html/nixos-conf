# NixOS Stable 26.05-pre | /home/sircam/.config/home-manager/

{ config, pkgs, ... }:

let
  # ── Bottles (remove warning popup) ───────────────────────────────────────────
  bottlesNoWarning = pkgs.bottles.override {
    removeWarningPopup = true;
  };

in {
  nixpkgs.config.permittedInsecurePackages = [ "pnpm-10.29.2" ];

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

  # ── Environment ───────────────────────────────────────────────────────────────
  home.sessionVariables = {
    QT_LOGGING_RULES = "qt.multimedia.*=false";
  };

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
    firefox
    discord
    ferdium

    # Dev / Productivity
    hydra-check
    devbox
    p7zip
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
  ];

  # ── Programs ──────────────────────────────────────────────────────────────────
  programs.home-manager.enable = true;

  # ── Fastfetch ─────────────────────────────────────────────────────────────────
  programs.fastfetch.enable = true;
}
