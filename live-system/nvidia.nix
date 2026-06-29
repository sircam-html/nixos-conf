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

  # ── NVIDIA Driver (Pinned 580.159.04) ────────────────────────────────────────────
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings     = true;
    open               = false;
    package            = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version            = "580.173.02";
      sha256_64bit       = "sha256-jY65AB4FqaimY9PV0wT+tk7yhE7hhczf2VJ4aCD0bhs=";
      sha256_aarch64     = "sha256-iRLyYjvHyDl2Xzb87j20o1MYNKLK/zql1JwSWbI3Kus=";
      openSha256         = "sha256-zsNmjZW0cyZWPp3vDT3mNeqAo0hS0M7e9Tbvwvij+F4=";
      settingsSha256     = "sha256-dfdu/3tnwHUfP7WoeQFNOMalMlpmUWjeMDIOnu+yi8E=";
      persistencedSha256 = "sha256-vDawiy52GB8JABUKZDiQUc8uda8p/7jCFW7rTu6QMa4=";
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
