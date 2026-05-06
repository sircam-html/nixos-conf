# NVIDIA Pascal (1070 Ti) Future-Proofing Guide for NixOS

## 📌 Context
NVIDIA's **580 branch** is the final Long-Term Support (LTS) branch for **Pascal-architecture GPUs** (10-series). Standard NixOS updates (e.g., moving to version 26.05 or 27.05) will eventually point the "stable" driver package to version 590+, which officially drops support for these cards.

This configuration uses the `mkDriver` function to "freeze" the driver version, ensuring your GPU continues to work regardless of system-wide updates.

## 🛠️ Current Working Configuration
Add this to your `configuration.nix`:

```nixos
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
```

## 🔄 How to Update in the Future
If NVIDIA releases a security patch within the 580 branch (e.g., **580.159**), follow these steps to update:

1. **Update Version:** Change the `version` string in your config to the new number.
2. **Reset Hashes:** Change the `sha256_64bit` and `settingsSha256` values to dummy zeros: 
   `"sha256-0000000000000000000000000000000000000000000="`
3. **Rebuild:** Run `sudo nixos-rebuild switch`.
4. **Catch the Mismatch:** Nix will fail and report a "got" hash. 
5. **Update Config:** Copy the hash from the error message into your configuration.
6. **Repeat:** Continue until the rebuild completes successfully.

---
