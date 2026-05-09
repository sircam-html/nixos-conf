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
    in
    (with pkgs; [
      # KDE
      kdePackages.isoimagewriter
      kdePackages.kolourpaint
      kdePackages.filelight
      kdePackages.ktorrent
      kdePackages.yakuake
      kdePackages.sweeper
      kdePackages.kcalc

      # Gaming/Streaming
      obs-studio

      # Browsers
      chromium

      # Dev/Productivity
      fastfetch
      opencode
      gedit
      fish
      htop


      # Multimedia
      youtube-music
      unrar
      vlc

    ]) ++ [ zen.default ];

  programs.home-manager.enable = true;
  programs.google-chrome.enable = true;

  home.stateVersion = "25.11";
}
