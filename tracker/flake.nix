{
  description = "NVIDIA 580 driver tracker — local inlined version";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs-unstable, nixpkgs-stable, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
        pkgs-stable = nixpkgs-stable.legacyPackages.${system};
        lu = pkgs-unstable.linuxPackages.nvidiaPackages.legacy_580;
        ls = pkgs-stable.linuxPackages.nvidiaPackages.legacy_580;
      in
      {
        packages.default = lu;

        apps.default = {
          type = "app";
          program = "${pkgs-unstable.writeShellScriptBin "nvidia-580-info" ''
            echo "╔══════════════════════════════════════════╗"
            echo "║        NVIDIA 580 Driver Tracker         ║"
            echo "╠══════════════════════════════════════════╣"
            printf "║ Unstable:    %-23s║\n" "${lu.version}"
            printf "║ Stable:      %-23s║\n" "${ls.version}"
            printf "║ Kernel (nix): %-22s║\n" "${pkgs-unstable.linuxPackages.kernel.version}"
            printf "║ Kernel (run): %-22s║\n" "$(uname -r)"
            echo "╠══════════════════════════════════════════╣"
            echo "║ nix build #mkDriver && cat result         ║"
            echo "╚══════════════════════════════════════════╝"
          ''}/bin/nvidia-580-info";
        };

        packages.mkDriver = pkgs-unstable.writeText "mkDriver-config" ''
          package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
            version            = "${lu.version}";
            sha256_64bit       = "sha256-weZnYbCI0Xs632y2l53przi+JoTRArABoXbc+vq9yh4=";
            sha256_aarch64     = "sha256-iRLyYjvHyDl2Xzb87j20o1MYNKLK/zql1JwSWbI3Kus=";
            openSha256         = "sha256-zsNmjZW0cyZWPp3vDT3mNeqAo0hS0M7e9Tbvwvij+F4=";
            settingsSha256     = "sha256-U0hics4gQeZWsD+ch9PBz42zfTOEVcKRVIqYZb3VOY8=";
            persistencedSha256 = "sha256-vDawiy52GB8JABUKZDiQUc8uda8p/7jCFW7rTu6QMa4=";
          };
        '';
      }
    );
}
