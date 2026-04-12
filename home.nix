{ config, pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.username = "sircam";
  home.homeDirectory = "/home/sircam";

  home.enableNixpkgsReleaseCheck = false;

  home.packages = with pkgs; [
    # KDE
    kdePackages.kolourpaint
    kdePackages.yakuake  
    kdePackages.filelight
    kdePackages.sweeper
    kdePackages.kcalc
    kdePackages.ktorrent  

    # Gaming/Streaming
    fastfetch
    steam
    wine
    bottles              
    mangohud             
    goverlay          
    obs-studio          

    # Browsers
    discord
    ferdium    
    brave
    chromium            
  

    # Dev/Productividad
    devbox
    fish
    htop
    gedit               
    youtube-music       

    # Multimedia
    unrar
    vlc                  

    # VMs (GUI)
    virt-manager        
  ];

  programs.home-manager.enable = true;
  programs.google-chrome.enable = true;
  
  home.stateVersion = "25.11";
}
