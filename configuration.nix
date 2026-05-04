# NixOS 25.11 + 580.142 = Stable, minimal base
# User apps: Home Manager (home.nix = 100% pure)

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking.
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Set time zone.
  time.timeZone = "America/Santo_Domingo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb.layout = "us";

  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sircam = {
    isNormalUser = true;
    description = "Cristian J. Hidalgo";
    extraGroups = [ "networkmanager" "wheel" "qemu-libvirtd" "libvirtd" ];
    packages = with pkgs; [ kdePackages.kate ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin = {
    enable = true;
    user = "sircam";
  };

  # Install/enable coolercontrol.
  programs.coolercontrol.enable = true;

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    libvirt
  ];

  # Enable graphics stack.
  hardware.graphics = {
    enable = true;
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

  # Enable proprietary NVIDIA driver with modesetting.
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Enable X server with NVIDIA driver.
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  # Environment variables for Wayland or X11.
  environment.sessionVariables = {
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
  };

  # Accept NVIDIA license.
  nixpkgs.config.nvidia.acceptLicense = true;

  # Kernel params for NVIDIA DRM KMS and AMD pstate power control
  boot.kernelParams = [ "nvidia-drm.modeset=1" "amd_pstate=passive" ];

  # Enable AMD CPU microcode updates for stability and performance.
  hardware.cpu.amd.updateMicrocode = true;

  # Enable thermald for dynamic thermal management (good for desktops).
  services.thermald.enable = true;

  # Enable TLP for advanced power management, desktop-optimized.
  services.tlp.enable = true;

  # TLP settings optimized for desktop (no battery-specific tuning).
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "schedutil";  # Balanced performance and efficiency.
    CPU_BOOST_ON_AC = 0;   # Disable CPU boost to reduce heat.
    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";  # Favor power saving while maintaining performance.
  };

  # Disable power-profiles-daemon to avoid conflicts with TLP.
  services.power-profiles-daemon.enable = false;

  # Enable powerManagement and disable CPU governor management to avoid conflicts.
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = null;

  # Disable automatic suspend and hibernation on desktop to prevent unwanted sleep.
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Enable Virtualization.
  virtualisation.libvirtd.enable = true;

  # Play Steam games locally.
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [ "steam" "steam-unwrapped" ];
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # Automatic cleanup/optimization.
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 10d";
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Disable password prompt.
  security.sudo.extraRules = [{
    users = [ "sircam" ];
    commands = [{
      command = "ALL";
      options = [ "SETENV" "NOPASSWD" ];
    }];
  }];

  # On boot Automatic cleanup.
  boot.tmp.cleanOnBoot = true;

  # Start system version.
  system.stateVersion = "25.05";
}
