{ config, pkgs, ... }:

{
  # ── Extra Module Packages ─────────────────────────────────────────────────────
  # Permite al kernel cargar correctamente el módulo del driver 470
  boot.extraModulePackages = [ config.hardware.nvidia.package ];

  # ── Nixpkgs Licenses ──────────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true; # <-- Aceptación de licencia requerida agregada aquí

  # ── Graphics Stack ────────────────────────────────────────────────────────────
  hardware.graphics = {
    enable      = true;
    enable32Bit = true; # Crucial para Bottles y launchers de 32 bits
    extraPackages = with pkgs; [
      libva-vdpau-driver
      libvdpau-va-gl
      nvidia-vaapi-driver # Soporte de aceleración Nvidia
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # ── NVIDIA Driver (Legacy 470 para GTX 690 - ACTIVO) ──────────────────────────
  hardware.nvidia = {
    # CRUCIAL: Debe estar en 'true' para que Wayland no vaya a tirones (2 FPS)
    modesetting.enable = true;
    nvidiaSettings     = true;
    open               = false; # Las tarjetas Kepler no soportan el driver open-source de Nvidia

    # Paquete oficial legacy_470 estructurado por NixOS
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  };

  # ── X Server (NVIDIA) ────────────────────────────────────────────────────────
  services.xserver = {
    enable       = true;
    videoDrivers = [ "nvidia" ];
  };

  # ── Session Variables (Ajustado para Nvidia Propietario) ─────────────────────
  environment.sessionVariables = {
    XDG_SESSION_TYPE          = "wayland";

    # Variables específicas de NVIDIA para fluidez en Wayland
    GBM_BACKEND               = "nvidia-drm";
    LIBVA_DRIVER_NAME         = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
