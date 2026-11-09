{ config, pkgs, ... }:

{
  # ── Extra Module Packages ─────────────────────────────────────────────────────
  boot.extraModulePackages = [ ];

  # ── Kernel & Firmware Adjustments ─────────────────────────────────────────────
  # Las tarjetas Intel Arc (Alchemist) requieren parches continuos y firmwares muy actualizados.
  # Se recomienda encarecidamente usar un kernel moderno (Linux 6.12+ o el último LTS estable).
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Habilita de forma explícita el firmware privativo necesario para cargar las funciones de la GPU Intel Arc.
  hardware.enableAllFirmware = true;

  # ── Graphics Stack ────────────────────────────────────────────────────────────
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver    # Modern Intel video acceleration driver (iHD) for VA-API
      vpl-gpu-rt            # Video Processing Library runtime for modern GPU features
      intel-compute-runtime # Enables OpenCL / Compute capabilities
      mesa.drivers          # Asegura la última implementación de ANV (Vulkan para Intel)
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver    # 32-bit video acceleration for older games/Wine
      vpl-gpu-rt
      mesa.drivers          # Vulkan de 32 bits esencial para Wine / Proton / Steam
    ];
  };

  # ── X Server (Intel Native) ───────────────────────────────────────────────────
  services.xserver = {
    enable       = true;
    videoDrivers = [ ];     # Correcto: Deja que el kernel asigne el driver i915/xe de forma nativa
  };

  # ── Session Variables (Wayland + Intel) ───────────────────────────────────────
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";       # Forces the system to use the modern Intel VA-API driver
    XDG_SESSION_TYPE  = "wayland";   # Keeps your native Wayland environment active
    NIXOS_OZONE_WL    = "1";         # Habilita soporte nativo de Wayland en apps Electron/Chromium

    # OPCIONAL: Si juegas títulos pesados a través de Proton/Wine y notas microstutters,
    # descomenta la siguiente línea para optimizar la compilación de shaders en Intel Mesa ANV:
    # ANV_QUEUE_THREAD_DISABLE = "1";
  };
}
