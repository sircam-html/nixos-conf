{ config, pkgs, ... }:

{
  # ── Extra Module Packages ─────────────────────────────────────────────────────
  boot.extraModulePackages = [ config.hardware.nvidia.package ];

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

  # ── NVIDIA Driver (Pinned 580.142) ────────────────────────────────────────────
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
}
