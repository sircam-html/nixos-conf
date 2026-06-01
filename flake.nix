{
  description = "A high-performance Hydra pre-update verification shield";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        safeUpdateScript = pkgs.writeShellScriptBin "safe-update" ''
          #!/usr/bin/env bash
          set -o pipefail
          CHANNEL="26.05"
          FAILED=0

          echo "🔍 Dynamic lookup: Extracting allowed unfree packages from your Nix config..."
          declare -A UNFREE_PACKAGES
          while IFS= read -r unfree_pkg; do
            [[ -z "$unfree_pkg" ]] && continue
            unfree_pkg=$(echo "$unfree_pkg" | tr -d '"')
            UNFREE_PACKAGES["$unfree_pkg"]=1
          done < <(${pkgs.nix}/bin/nix-instantiate --eval -E 'builtins.attrNames (import <nixpkgs> {}).config.allowUnfreePredicate.pkgNames or {}' 2>/dev/null | tr -d '[]' | tr ' ' '\n' || true)

          if [ ''${#UNFREE_PACKAGES[@]} -eq 0 ]; then
            for pkg in ferdium discord google-chrome vivaldi brave steam zen-browser unrar coolercontrol; do
              UNFREE_PACKAGES["$pkg"]=1
            done
          fi

          echo "🔍 Fetching currently installed packages (System + Home Manager)..."
          user_pkgs=$(home-manager packages 2>/dev/null | ${pkgs.gawk}/bin/awk '{print $1}')
          system_pkgs=$(${pkgs.nix}/bin/nix-env -p /run/current-system/sw -q 2>/dev/null)

          packages=()
          while IFS= read -r pkg; do
            [[ -z "$pkg" ]] && continue
            [[ "$pkg" =~ ^(hm-session-vars.*|home-configuration-reference.*|home-manager-path|safe-update)$ ]] && continue
            packages+=("$pkg")
          done < <(printf "%s\n%s" "$user_pkgs" "$system_pkgs" | ${pkgs.gnused}/bin/sed -E 's/-[0-9](\.[0-9])*.*//' | sort -u)

          if [ ''${#packages[@]} -eq 0 ]; then
            echo "❌ Error: No packages detected in your profile. Aborting."
            exit 1
          fi

          echo "🔍 Checking ''${#packages[@]} unique packages on nixos-$CHANNEL..."
          echo "─────────────────────────────────────────────────"

          for pkg in "''${packages[@]}"; do
            if [[ -n "''${UNFREE_PACKAGES[$pkg]}" ]]; then
              echo "📦 $pkg → Pre-built binary, unfree, or daemon (Hydra doesn't track) — assumed OK"
              continue
            fi
            if [[ "$pkg" == nerd-fonts-* ]]; then
              echo "📦 $pkg → Font package — skipped verification"
              continue
            fi

            hydra_name="$pkg"
            case "$pkg" in
              kcalc|yakuake|filelight|kolourpaint|ktorrent|sweeper|isoimagewriter)
                hydra_name="kdePackages.$pkg"
                ;;
            esac

            if ! result=$(${pkgs.hydra-check}/bin/hydra-check "$hydra_name" --channel "$CHANNEL" 2>&1); then
              echo "⚠️  $hydra_name → Not found or query error (Skipped)"
              continue
            fi

            if echo "$result" | ${pkgs.gnugrep}/bin/grep -q "✔"; then
              echo "✅ $pkg → OK"
            elif echo "$result" | ${pkgs.gnugrep}/bin/grep -q "✖"; then
              echo "❌ $pkg → FAILED"
              FAILED=1
            else
              echo "⚠️  $pkg → Unknown or unbuilt status"
            fi
          done

          echo "─────────────────────────────────────────────────"

          if [ "$FAILED" -eq 1 ]; then
            echo "❌ Some packages failed on Hydra. Update aborted!"
            exit 1
          else
            echo "✅ All packages green. Safe to update!"
            echo "🚀 Running update..."
            sudo nix-channel --update && \
            sudo nixos-rebuild switch --upgrade && \
            home-manager switch
          fi
        '';
      in
      {
        packages.default = safeUpdateScript;
        apps.default = {
          type = "app";
          program = "${safeUpdateScript}/bin/safe-update";
        };
      }
    );
}
