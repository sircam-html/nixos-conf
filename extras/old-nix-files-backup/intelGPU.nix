{ config, pkgs, ... }:

{
  # ── Extra Module Packages ─────────────────────────────────────────────────────
  # Nvidia-specific module packages removed as Intel drivers are built directly into the kernel.
  boot.extraModulePackages = [ ];

  # ── Graphics Stack ────────────────────────────────────────────────────────────
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver   # Modern Intel video acceleration driver (iHD) for VA-API
      vpl-gpu-rt           # Video Processing Library runtime for modern GPU features
      intel-compute-runtime # Enables OpenCL / Compute capabilities
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver   # 32-bit video acceleration for older games/Wine
      vpl-gpu-rt
    ];
  };

  # ── X Server (Intel Native) ───────────────────────────────────────────────────
  services.xserver = {
    enable       = true;
    # Left empty to let the modern kernel automatically load the open-source Intel "i915/xe" driver.
    # Avoid setting this to "intel" as that option is legacy and intended for older iGPUs.
    videoDrivers = [ ];
  };

  # ── Session Variables (Wayland + Intel) ───────────────────────────────────────
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";       # Forces the system to use the modern Intel VA-API driver
    XDG_SESSION_TYPE  = "wayland";   # Keeps your native Wayland environment active
    NIXOS_OZONE_WL    = "1";         # Habilita soporte nativo de Wayland en apps Electron/Chromium
  };
}




# Usar sudo nixos-rebuild boot para aplciar nueva configuración la cual creara un generation listo para la Arc.


#
Pasos para activar Re-BAR en tu Gigabyte B550:

1. Reinicia tu computadora y presiona repetidamente la tecla Supr (Delete) o F2 en tu teclado para entrar a la BIOS.

2. Si la BIOS inicia en el "Easy Mode" (Modo Fácil), presiona la tecla F2 para cambiar al Advanced Mode (Modo Avanzado).

3. Desactiva el soporte heredado: 
Ve a la pestaña Boot y cambia CSM Support a Disabled (esto es seguro ahora, 
ya que la Intel Arc es 100% nativa UEFI, a diferencia de tu vieja GTX 690).

4. Entra en la sección llamada IO Ports.

5. Busca la opción Above 4G Decoding y cámbiala a Enabled (Habilitado).

6. Justo debajo aparecerá la opción Re-Size BAR Support (a veces oculta hasta que activas el paso anterior). Cámbiala a Auto.

7. Por último, ve a la pestaña Boot (en el menú superior) y asegúrate de que la opción CSM Support esté en Disabled (Deshabilitado), ya que Re-BAR requiere el modo UEFI puro para funcionar.

8. Presiona F10 para guardar los cambios y salir.
