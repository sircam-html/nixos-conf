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
            RULER=$(printf '%64s' | tr ' ' '=')
            echo "$RULER"
            echo "  Last mkDriver version available — update your hashes now!"
            echo "$RULER"
            echo "  package = config.boot.kernelPackages.nvidiaPackages.mkDriver {"
            echo "    version = \"${lu.version}\";"
            echo "  };"
            echo ""
            echo "$RULER"
            printf "  Unstable: %-20s  Stable: %s\n" "${lu.version}" "${ls.version}"
            printf "  Kernel:   %-20s  Running: %s\n" "${pkgs-unstable.linuxPackages.kernel.version}" "$(uname -r)"
            echo "$RULER"
            echo "  Copy the block above, paste into nvidia.nix,"
            echo "  then fetch fresh hashes from nixpkgs master."
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
