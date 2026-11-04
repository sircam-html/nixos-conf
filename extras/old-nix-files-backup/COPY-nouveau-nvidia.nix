 { config, pkgs, ... }:

{
  # ── Extra Module Packages ─────────────────────────────────────────────────────
  # Comentado temporalmente: Evita que el kernel intente cargar el módulo pesado 580 en la GTX 690
  # boot.extraModulePackages = [ config.hardware.nvidia.package ];

  # ── Graphics Stack ────────────────────────────────────────────────────────────
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva-vdpau-driver
      libvdpau-va-gl
      # Desactivado temporalmente para Nouveau
      # nvidia-vaapi-driver
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # ── NVIDIA Driver (Pinned 580 Set - Preservado e Inactivo) ───────────────────
  hardware.nvidia = {
    modesetting.enable = false; # Desactivar mientras uses Nouveau
    nvidiaSettings     = false; # Desactivar mientras uses Nouveau
    open               = false;
    package            = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version            = "580.196.07";
      sha256_64bit       = "sha256-CqsFGNtTz3PEEtx/MrvIUMqV6DnYkj0N5L/0LByRac4=";
      sha256_aarch64     = "sha256-iRLyYjvHyDl2Xzb87j20o1MYNKLK/zql1JwSWbI3Kus=";
      openSha256         = "sha256-zsNmjZW0cyZWPp3vDT3mNeqAo0hS0M7e9Tbvwvij+F4=";
      settingsSha256     = "sha256-KcrGHoR+ZMdsFyI4myU8/eVls2f8GkNSX/j2JnZndyM=";
      persistencedSha256 = "sha256-vDawiy52GB8JABUKZDiQUc8uda8p/7jCFW7rTu6QMa4=";
    };
  };

  # ── X Server / Driver de Video Emergencia (Nouveau) ───────────────────────────
  services.xserver = {
    enable       = true;
    # Cambiado temporalmente a "nouveau" para darte resolución nativa en tu escritorio
    videoDrivers = [ "nouveau" ];
  };

  # ── Session Variables (Ajustado para Nouveau) ─────────────────────────────────
  environment.sessionVariables = {
    XDG_SESSION_TYPE          = "wayland"; # Nouveau maneja Wayland de forma nativa mediante Mesa/GBM
    # Comentadas temporalmente las variables específicas del driver propietario de NVIDIA:
    # GBM_BACKEND               = "nvidia-drm";
    # LIBVA_DRIVER_NAME         = "nvidia";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
