# NVIDIA Pascal Future-Proofing Guide for NixOS

## 📌 Context
NVIDIA's **580 branch** is the final Long-Term Support (LTS) branch for **Pascal-architecture GPUs** (10-series). Standard NixOS updates (e.g., moving to version 26.05 or 27.05) will eventually point the "stable" driver package to version 590+, which officially drops support for these cards.

These configurations uses the `mkDriver` function to "freeze" the driver version, ensuring your GPU continues to work regardless of system-wide updates.

## 🛠️ Current Working Configuration
Add this to your `configuration.nix`:

```nixos
  # ── NVIDIA Driver (Pinned 580.142) ─--───────────────────────────────────────────
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

##

  # ── NVIDIA Driver (Pinned 580.159.04) ────────────────────────────────────────────
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings     = true;
    open               = false;
    package            = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version            = "580.159.04";
      sha256_64bit       = "sha256-weZnYbCI0Xs632y2l53przi+JoTRArABoXbc+vq9yh4=";
      sha256_aarch64     = "sha256-iRLyYjvHyDl2Xzb87j20o1MYNKLK/zql1JwSWbI3Kus=";
      openSha256         = "sha256-zsNmjZW0cyZWPp3vDT3mNeqAo0hS0M7e9Tbvwvij+F4=";
      settingsSha256     = "sha256-U0hics4gQeZWsD+ch9PBz42zfTOEVcKRVIqYZb3VOY8=";
      persistencedSha256 = "sha256-vDawiy52GB8JABUKZDiQUc8uda8p/7jCFW7rTu6QMa4=";
    };
  };
```

## 📝 Note on the Hashes
You will notice that only **`sha256_64bit`** and **`settingsSha256`** contain real values, while the others are zeros. This is expected:
* **`sha256_64bit`**: The core driver for standard PCs. Nix downloads this first.
* **`settingsSha256`**: The GUI settings tool.
* **The Zeros**: Nix only checks hashes for files it actually downloads. Since you are likely on an x86_64 PC and have `open = false`, Nix ignores the ARM (`aarch64`) and `open` source files entirely.

## 🔄 How to Update in the Future
If NVIDIA releases a security patch within the 580 branch (e.g., **580.159**), follow these steps to update:

1. **Update Version:** Change the `version` string in your config to the new number.
2. **Reset Hashes:** Change the `sha256_64bit` and `settingsSha256` values back to dummy zeros: 
   `"sha256-0000000000000000000000000000000000000000000="`
3. **Rebuild:** Run `sudo nixos-rebuild switch`.
4. **Catch the Mismatch:** Nix will fail and report a "got" hash. 
5. **Update Config:** Copy the hash from the error message into your configuration.
6. **Repeat:** Continue until the rebuild completes successfully.

```
# ── OPTIONAL NVIDIA Driver (Legacy_580) ───────────────────────────────────────────────────
hardware.nvidia = {
  modesetting.enable = true;
  nvidiaSettings     = true;
  open               = false;
  package            = config.boot.kernelPackages.nvidiaPackages.legacy_580;
};
```
