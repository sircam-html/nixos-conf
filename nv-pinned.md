  # --- PASCAL GPU (1070 Ti) FUTURE-PROOFING GUIDE ---
  # 
  # WHY THIS IS HERE:
  # NVIDIA's 580 branch is the final LTS branch for Pascal. Standard NixOS updates
  # (like moving to 26.05 or 27.05) will eventually point to 590+, which breaks this GPU.
  # This 'mkDriver' block freezes the driver version so your GPU works forever.
  #
  # HOW TO UPDATE TO A NEWER 580.x VERSION IN THE FUTURE:
  # 1. Change 'version' to the new number (e.g., "580.159").
  # 2. Change 'sha256_64bit' and 'settingsSha256' to dummy zeros: 
  #    "sha256-0000000000000000000000000000000000000000000="
  # 3. Run 'sudo nixos-rebuild switch'.
  # 4. Nix will fail and say "got: sha256-abc...". Copy that hash and paste it in.
  # 5. Repeat until the build succeeds.

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "580.142";
      sha256_64bit = "sha256-IJFfzz/+icNVDPk7YKBKKFRTFQ2S4kaOGRGkNiBEdWM=";
      sha256_aarch64 = "sha256-0000000000000000000000000000000000000000000=";
      openSha256 = "sha256-0000000000000000000000000000000000000000000=";
      settingsSha256 = "sha256-BnrIlj5AvXTfqg/qcBt2OS9bTDDZd3uhf5jqOtTMTQM=";
      persistencedSha256 = "sha256-0000000000000000000000000000000000000000000=";
    };
  };
