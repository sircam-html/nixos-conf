# NixOS Stable 26.05 (Yarara) | x86_64

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./amd-cpu.nix
  ];

  # ── Bootloader ────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Plymouth Boot Splash ──────────────────────────────────────────────────────
  boot.plymouth = {
    enable        = true;
    theme         = "nixos-bgrt";
    themePackages = [ pkgs.nixos-bgrt-plymouth ];
  };
  boot.initrd.systemd.enable = true;
  boot.consoleLogLevel       = 0;
  boot.initrd.verbose        = false;

  # ── Kernel Params ─────────────────────────────────────────────────────────────
  boot.kernelParams = [ "quiet" "splash" "udev.log_level=3" ];

  # ── Networking ────────────────────────────────────────────────────────────────
  networking.hostName              = "nixos";
  networking.networkmanager.enable = true;

  # ── Time Zone ─────────────────────────────────────────────────────────────────
  time.timeZone = "America/Santo_Domingo";

  # ── Internationalisation ──────────────────────────────────────────────────────
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT    = "en_US.UTF-8";
    LC_MONETARY       = "en_US.UTF-8";
    LC_NAME           = "en_US.UTF-8";
    LC_NUMERIC        = "en_US.UTF-8";
    LC_PAPER          = "en_US.UTF-8";
    LC_TELEPHONE      = "en_US.UTF-8";
    LC_TIME           = "en_US.UTF-8";
  };

  # ── Keyboard Layout ───────────────────────────────────────────────────────────
  services.xserver.xkb.layout  = "us";
  services.xserver.xkb.variant = "altgr-intl";
  services.xserver.enable      = true;

  # ── KDE Plasma Desktop ────────────────────────────────────────────────────────
  services.displayManager.sddm.enable    = true;
  services.desktopManager.plasma6.enable = true;

  # ── Printing ──────────────────────────────────────────────────────────────────
  services.printing.enable = true;

  # ── Sound (PipeWire) ──────────────────────────────────────────────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable      = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
  };

  # ── User Account ──────────────────────────────────────────────────────────────
  users.users.sircam = {
    isNormalUser = true;
    description  = "Cristian J. Hidalgo";
    extraGroups  = [ "networkmanager" "wheel" "qemu-libvirtd" "libvirtd" ];
    packages     = with pkgs; [ kdePackages.kate ];
  };

  # ── Auto Login ────────────────────────────────────────────────────────────────
  services.displayManager.autoLogin = {
    enable = true;
    user   = "sircam";
  };

  # ── Sudo (no password prompt) ─────────────────────────────────────────────────
  security.sudo.extraRules = [{
    users = [ "sircam" ];
    commands = [{
      command = "ALL";
      options = [ "SETENV" "NOPASSWD" ];
    }];
  }];

  # ── CoolerControl ─────────────────────────────────────────────────────────────
  programs.coolercontrol.enable = true;

  # ── SSD Health Monitoring ────────────────────────────────────────────────
  services.smartd.enable = true;

  # ── Allow Unfree Packages ─────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "pnpm-10.29.2" ];

  # ── System Packages ───────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    libvirt
    smartmontools
  ];

  # ── Virtualization ────────────────────────────────────────────────────────────
  virtualisation.libvirtd.enable = true;

  # ── Steam ─────────────────────────────────────────────────────────────────────
  programs.steam = {
    enable                                = true;
    remotePlay.openFirewall               = true;
    dedicatedServer.openFirewall          = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # ── Nix Store Cleanup / Optimization ─────────────────────────────────────────
  nix.gc.automatic                   = true;
  nix.gc.dates                       = "weekly";
  nix.gc.options                     = "--delete-older-than 10d";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ── Clean /tmp on Boot ────────────────────────────────────────────────────────
  boot.tmp.cleanOnBoot = true;
  boot.tmp.useTmpfs    = true;

  # ── State Version ─────────────────────────────────────────────────────────────
  system.stateVersion = "25.05";
}
