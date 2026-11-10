{ config, pkgs, ... }:

{
  # ── Nixpkgs Licenses ──────────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;

  # ── Graphics Stack ────────────────────────────────────────────────────────────
  hardware.graphics = {
    enable      = true;
    enable32Bit = true; # Crucial para compatibilidad de librerías de 32 bits
    extraPackages = with pkgs; [
      libva-vdpau-driver
      libvdpau-va-gl
      nvidia-vaapi-driver   # Soporte de aceleración por hardware Nvidia (NVDEC)
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # ── NVIDIA Driver (Legacy 470 para GTX 690 - ACTIVO) ──────────────────────────
  hardware.nvidia = {
    modesetting.enable = true; # CRUCIAL: Mantiene Wayland fluido y evita los tirones
    nvidiaSettings     = true; # Mantiene la comunicación con los sensores de la tarjeta
    open               = false; # Las tarjetas Kepler no soportan el driver open-source

    # Paquete oficial legacy_470 estructurado por NixOS
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  };

  # ── X Server (NVIDIA) ────────────────────────────────────────────────────────
  services.xserver = {
    enable       = true;
    videoDrivers = [ "nvidia" ];
  };

  # ── Session Variables (Optimizadas para Nvidia Propietario en Wayland) ────────
  environment.sessionVariables = {
    XDG_SESSION_TYPE          = "wayland";

    # Variables específicas de NVIDIA para fluidez en Wayland
    GBM_BACKEND               = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";

    # Enlaza correctamente nvidia-vaapi-driver para aceleración de video
    LIBVA_DRIVER_NAME         = "nvidia";

    # ── AGREGADO: Forzar decodificación directa en el backend de NVIDIA ─────────
    # Mejora drásticamente el rendimiento de video en navegadores y apps de escritorio
    NVD_BACKEND               = "direct";
  };
}
