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
            DRIVER=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || echo "unknown")
            RULER=$(printf '%52s' | tr ' ' '=')
            echo "$RULER"
            if [ "${lu.version}" != "$DRIVER" ]; then
              printf "  ⚠ New mkDriver version:  %s\n" "${lu.version}"
            else
              printf "  ✓ Current driver up to date:  %s\n" "${lu.version}"
            fi
            echo "$RULER"
            printf "  Unstable: %-20s  Stable: %s\n" "${lu.version}" "${ls.version}"
            printf "  Kernel:   %-20s  Running: %s\n" "${pkgs-unstable.linuxPackages.kernel.version}" "$(uname -r)"
            echo "$RULER"
          ''}/bin/nvidia-580-info";
        };

        packages.mkDriver = pkgs-unstable.writeText "mkDriver-config" ''
          package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
            version = "${lu.version}";
          };
        '';
      }
    );
}
