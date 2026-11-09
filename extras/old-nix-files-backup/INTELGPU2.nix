{ config, pkgs, ... }:

{
  # ── Extra Module Packages ─────────────────────────────────────────────────────
  # Los controladores de Intel vienen integrados directamente en el kernel.
  boot.extraModulePackages = [ ];

  # ── Kernel y Firmware (Esencial para la estabilidad de Intel Arc) ──────────────
  # Se recomienda usar el kernel más reciente para obtener las últimas mejoras del driver.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Habilita el firmware privativo necesario para inicializar correctamente la GPU.
  hardware.enableAllFirmware = true;

  # ── Graphics Stack (Optimizado para Steam, Bottles y Heroic) ──────────────────
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
    
    # Paquetes y controladores nativos de 64 bits
    extraPackages = with pkgs; [
      intel-media-driver    # Aceleración de video moderna (iHD) para VA-API
      vpl-gpu-rt            # Runtime multimedia (Video Processing Library)
      intel-compute-runtime # Habilita OpenCL / Cómputo en la GPU
      mesa.drivers          # Driver Vulkan nativo de Intel (ANV)
    ];
    
    # Paquetes de 32 bits esenciales para juegos antiguos (UT99) y capas de emulación (Wine/Proton)
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver    # Aceleración de video de 32 bits
      vpl-gpu-rt
      intel-compute-runtime # Permite que launchers de 32 bits reconozcan las capacidades de la GPU
      mesa.drivers          # Driver Vulkan de Intel de 32 bits (Crucial para DXVK)
    ];
  };

  # ── X Server (Carga Automática Intel) ─────────────────────────────────────────
  services.xserver = {
    enable       = true;
    # Se deja vacío para evitar el uso del driver "intel" heredado (antiguo) 
    # y permitir que el sistema asigne automáticamente los módulos modernos.
    videoDrivers = [ ];     
  };

  # ── Variables de Entorno (Wayland + Rendimiento) ──────────────────────────────
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";       # Fuerza el renderizado mediante el driver VA-API moderno
    XDG_SESSION_TYPE  = "wayland";   # Mantiene activo tu entorno nativo de Wayland
    NIXOS_OZONE_WL    = "1";         # Habilita compatibilidad nativa de Wayland en aplicaciones electron
    
    # OPTATIVO: Descomenta la siguiente línea si experimentas microstutters en servidores
    # privados muy masivos ejecutados bajo capas de traducción a Vulkan:
    # ANV_QUEUE_THREAD_DISABLE = "1";
  };
}
