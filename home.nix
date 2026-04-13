{ config, pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.username = "sircam";
  home.homeDirectory = "/home/sircam";

  home.enableNixpkgsReleaseCheck = false;

  home.packages =
    # Zen Browser
    let
      zen = import (builtins.fetchTarball "https://github.com/youwen5/zen-browser-flake/archive/master.tar.gz") {
        inherit pkgs;
      };
      # Bottles override (remove warning popup)
      bottlesNoWarning = pkgs.bottles.override {
        removeWarningPopup = true;
      };
    in
    (with pkgs; [
      # KDE
      kdePackages.kolourpaint
      kdePackages.filelight
      kdePackages.ktorrent
      kdePackages.yakuake
      kdePackages.sweeper
      kdePackages.kcalc

      # Gaming/Streaming
      obs-studio
      fastfetch
      mangohud
      goverlay
      bottlesNoWarning  # ← REEMPLAZA bottles

      heroic
      steam
      wine

      # Browsers
      chromium
      ferdium
      discord
      brave

      # Dev/Productividad
      devbox
      gedit
      fish
      htop
      git

      # Multimedia
      youtube-music
      unrar
      vlc

      # VMs (GUI)
      virt-manager
    ]) ++ [ zen.default ];

  programs.home-manager.enable = true;
  programs.firefox.enable = true;
  programs.google-chrome.enable = true;

  home.stateVersion = "25.11";
}
