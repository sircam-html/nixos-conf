# NixOS 26.05pre + pinned nvidia drivers 580.142
# User apps: Home Manager (home.nix = 100% pure)

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # ── Extra Module Packages ─────────────────────────────────────────────────────
  boot.extraModulePackages = [ config.hardware.nvidia.package ];

  # ── Bootloader ────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Plymouth Boot Splash ──────────────────────────────────────────────────────
  boot.plymouth = {
    enable          = true;
    theme           = "nixos-bgrt";
    themePackages   = [ pkgs.nixos-bgrt-plymouth ];
  };
  boot.initrd.systemd.enable = true;
  boot.consoleLogLevel       = 0;
  boot.initrd.verbose        = false;

  # ── Kernel Params ─────────────────────────────────────────────────────────────
  # NVIDIA DRM KMS, AMD pstate power control and Plymouth
  boot.kernelParams = [ "nvidia-drm.modeset=1" "amd_pstate=passive" "quiet" "splash" "udev.log_level=3" ];

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
  # US layout with AltGr international variant for Spanish accents and ñ
  services.xserver.xkb.layout  = "us";
  services.xserver.xkb.variant = "altgr-intl";

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

  # ── CoolerControl ─────────────────────────────────────────────────────────────
  programs.coolercontrol.enable = true;

  # ── Allow Unfree Packages ─────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  # ── System Packages ───────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    libvirt
  ];

  # ── Graphics Stack ────────────────────────────────────────────────────────────
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva-vdpau-driver
      libvdpau-va-gl
      nvidia-vaapi-driver
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva-vdpau-driver
      libvdpau-va-gl
      nvidia-vaapi-driver
    ];
  };

  # ── NVIDIA Driver (pinned to 580.142) ─────────────────────────────────────────
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings     = true;
    open               = false;
    package            = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version            = "580.142";
      sha256_64bit       = "sha256-IJFfzz/+icNVDPk7YKBKKFRTFQ2S4kaOGRGkNiBEdWM=";
      sha256_aarch64     = "sha256-0000000000000000000000000000000000000000000=";
      openSha256         = "sha256-0000000000000000000000000000000000000000000=";
      settingsSha256     = "sha256-BnrIlj5AvXTfqg/qcBt2OS9bTDDZd3uhf5jqOtTMTQM=";
      persistencedSha256 = "sha256-0000000000000000000000000000000000000000000=";
    };
  };

  # ── X Server (NVIDIA) ─────────────────────────────────────────────────────────
  services.xserver = {
    enable       = true;
    videoDrivers = [ "nvidia" ];
  };

  # ── Session Variables (Wayland + NVIDIA) ──────────────────────────────────────
  environment.sessionVariables = {
    GBM_BACKEND               = "nvidia-drm";
    LIBVA_DRIVER_NAME         = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    XDG_SESSION_TYPE          = "wayland";
  };

  # ── AMD CPU Microcode ─────────────────────────────────────────────────────────
  hardware.cpu.amd.updateMicrocode = true;

  # ── TLP Power Management (desktop-optimized) ──────────────────────────────────
  services.tlp.enable = true;
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_AC   = "schedutil";     # Balanced performance and efficiency
    CPU_BOOST_ON_AC              = 0;               # Disable CPU boost to reduce heat
    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power"; # Favor power saving while maintaining performance
  };

  # ── Disable power-profiles-daemon (conflicts with TLP) ───────────────────────
  services.power-profiles-daemon.enable = false;

  # ── Power Management ──────────────────────────────────────────────────────────
  powerManagement.enable          = true;
  powerManagement.cpuFreqGovernor = null;

  # ── Disable Sleep / Hibernation ───────────────────────────────────────────────
  systemd.sleep.settings.Sleep = {
    AllowSuspend              = "no";
    AllowHibernation          = "no";
    AllowHybridSleep          = "no";
    AllowSuspendThenHibernate = "no";
  };

  # ── Virtualization ────────────────────────────────────────────────────────────
  virtualisation.libvirtd.enable = true;

  # ── Flatpak ───────────────────────────────────────────────────────────────────
  services.flatpak.enable = true;

  # ── Steam ─────────────────────────────────────────────────────────────────────
  programs.steam = {
    enable                                = true;
    remotePlay.openFirewall               = true;
    dedicatedServer.openFirewall          = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # ── Nix Store Cleanup / Optimization ─────────────────────────────────────────
  nix.gc.automatic                   = true;
  nix.gc.dates                       = "daily";
  nix.gc.options                     = "--delete-older-than 10d";
  nix.settings.auto-optimise-store   = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ── Sudo (no password prompt) ─────────────────────────────────────────────────
  security.sudo.extraRules = [{
    users = [ "sircam" ];
    commands = [{
      command = "ALL";
      options = [ "SETENV" "NOPASSWD" ];
    }];
  }];

  # ── Clean /tmp on Boot ────────────────────────────────────────────────────────
  boot.tmp.cleanOnBoot = true;

  # ── State Version ─────────────────────────────────────────────────────────────
  system.stateVersion = "25.05";
}
