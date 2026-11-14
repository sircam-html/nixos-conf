{ config, pkgs, ... }:

{
  # ── Graphics Stack ──────────────────────────────────────────────────────────
  hardware.graphics = {
    enable      = true;
    enable32Bit = true; # Required for Steam / Wine / 32-bit games

    extraPackages = with pkgs; [
      nvidia-vaapi-driver # VA-API hardware video decoding on NVIDIA
    ];
  };

  # ── NVIDIA Driver (Production + KDE Wayland) ────────────────────────────────
  hardware.nvidia = {
    modesetting.enable = true; # Required for Wayland (enables nvidia-drm.modeset=1)

    # Only affects suspend/hibernate; suspend is disabled, so keep it off
    powerManagement.enable = false;

    nvidiaSettings = true;

    # Open kernel modules (supported on Ampere / RTX 3070)
    # Fallback: set to false if you hit instability
    open = true;

    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  # ── Driver Loading ──────────────────────────────────────────────────────────
  # Still required on Wayland: this is what loads the NVIDIA kernel module
  services.xserver.videoDrivers = [ "nvidia" ];

  # ── Session Variables ───────────────────────────────────────────────────────
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia"; # Use nvidia-vaapi-driver for VA-API
    NIXOS_OZONE_WL    = "1";      # Native Wayland for Electron / Chromium apps
  };
}
