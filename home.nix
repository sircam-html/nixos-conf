{ config, pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.username = "sircam";
  home.homeDirectory = "/home/sircam";

  home.enableNixpkgsReleaseCheck = false;

  home.packages =
    let
      zen = import (builtins.fetchTarball "https://github.com/youwen5/zen-browser-flake/archive/master.tar.gz") {
        inherit pkgs;
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
      bottles
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
