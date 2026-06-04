# NixOS 26.05 Stable | /home/sircam/.config/home-manager/

{ config, pkgs, ... }:

let
  # ── Zen Browser ───────────────────────────────────────────────────────────────
  # Unpinned on purpose: pulls latest from master on every switch
  zen = import (builtins.fetchTarball
    "https://github.com/youwen5/zen-browser-flake/archive/master.tar.gz"
  ) { inherit pkgs; };

  # ── Bottles (remove warning popup) ───────────────────────────────────────────
  bottlesNoWarning = pkgs.bottles.override {
    removeWarningPopup = true;
  };

in {

  # ── User ──────────────────────────────────────────────────────────────────────
  home.username                  = "sircam";
  home.homeDirectory             = "/home/sircam";
  home.stateVersion              = "25.11";
  home.enableNixpkgsReleaseCheck = false;
  news.display                   = "silent";
  nixpkgs.config.allowUnfree     = true;

  # ── Fonts ─────────────────────────────────────────────────────────────────────
  fonts.fontconfig.enable = true;

  # ── Packages ──────────────────────────────────────────────────────────────────
  home.packages = (with pkgs; [

    # KDE
    kdePackages.isoimagewriter
    kdePackages.kolourpaint
    kdePackages.filelight
    kdePackages.ktorrent
    kdePackages.yakuake
    kdePackages.sweeper
    kdePackages.kcalc

    # Gaming / Streaming
    coolercontrol.coolercontrol-gui
    bottlesNoWarning
    obs-studio
    mangohud
    goverlay
    heroic
    steam
    wine

    # Browsers
    discord
    ferdium

    # Dev / Productivity
    hydra-check
    devbox
    htop
    tmux
    git

    # Multimedia
    pear-desktop
    unrar
    vlc

    # VMs
    virt-manager

    # Fonts
    nerd-fonts.jetbrains-mono  # great terminal font
    nerd-fonts.fira-code

  ]) ++ [
    zen.default  # Zen Browser — sourced outside nixpkgs via fetchTarball
  ];

  # ── Programs ──────────────────────────────────────────────────────────────────
  programs.home-manager.enable = true;

  # ── Fastfetch ─────────────────────────────────────────────────────────────────
  # Managed via Home Manager, preset set via ff alias
  programs.fastfetch.enable = true;

  # ── Fish Shell Configuration ──────────────────────────────────────────────────
  programs.fish = {
    enable = true;

    functions = {
      # Native Fish function that captures your text and pushes automatically
      lazy-push = ''
        git add .
        git commit -m "$argv"
        git push origin main
      '';

      # Backup/sync NixOS configs to GitHub
      backup = ''
        set -l REPO "$HOME/nixos-conf"
        set -l DEST "26.05-stable-cfg"

        if test ! -d "$REPO"
          git clone git@github.com:sircam-html/nixos-conf.git "$REPO"
        end

        cp ~/.config/home-manager/home.nix "$REPO/$DEST/"
        cp /etc/nixos/configuration.nix "$REPO/$DEST/"

        cd "$REPO"
        if git diff --quiet && git diff --cached --quiet
          echo "✓ No changes — already up to date"
          return 0
        end

        git add -A
        git commit -m "sync: $(date '+%Y-%m-%d %H:%M')"
        git push origin main
        echo "✓ Configs backed up to GitHub"
      '';
    };

    shellAliases = {
      # Backup all configs to GitHub
      bu          = "backup";
      # Dry-run Hydra check (audit only, no update)
      safe-check  = "nix run github:sircam-html/safe-update-nix --override-input nixpkgs nixpkgs -- --check";
      # Hyper-localized execution (Bypasses downloads, instantly evaluates via system cache)
      safe-update = "nix run github:sircam-html/safe-update-nix --override-input nixpkgs nixpkgs";
      # Update system and home-manager
      update      = "sudo nix-channel --update && sudo nixos-rebuild switch --upgrade && home-manager switch";
      # Full system cleanup
      trim        = "nix-collect-garbage -d && sudo nix-collect-garbage -d && sudo nix-env --delete-generations old && sudo nixos-rebuild boot && home-manager expire-generations '2 weeks ago' && nix store optimise";
      # Home Manager switch
      hm          = "home-manager switch";
      # NixOS rebuild
      nr          = "sudo nixos-rebuild switch";
      # Edit system config
      cn          = "kate /etc/nixos/configuration.nix";
      # Edit home config
      hn          = "kate ~/.config/home-manager/home.nix";
      # Nix garbage collect (user + system)
      gc          = "nix-collect-garbage -d && sudo nix-collect-garbage -d";
      # Delete old Nix generations and update bootloader
      dg          = "sudo nix-env --delete-generations old && sudo nixos-rebuild boot";
      # Nix store optimise
      op          = "nix store optimise";
      # Restart KDE Plasma shell
      ps          = "systemctl --user restart plasma-plasmashell";
      # Fastfetch with custom preset
      ff          = "fastfetch -c examples/25";
      # Check all channels (user + system)
      ch          = "sudo nix-channel --list && echo '───' && nix-channel --list";
      # Check NixOS and Home Manager versions and revision
      ver         = "nixos-version && nixos-version --revision && home-manager --version";
      # Hydra build status check
      hc          = "hydra-check";
      # Launch Caddy server inside Devbox for local websites
      servers     = "cd /home/sircam/_devbox/ && devbox run caddy run --config Caddyfile";
      # Launch and update Google Chrome on-the-fly straight from the cloud sandbox
      chrome      = "nix run github:sircam-html/chrome-sandbox --override-input nixpkgs nixpkgs";
      # PLAN B: Emergency alias to instantly factory-reset the Chrome sandbox space
      chrome-wipe = "rm -rf ~/.cache/chrome-sandbox && echo '🧹 Chrome sandbox has been completely wiped!'";

      # Launch private OpenCode interface silently inside a detached background session via flat Fish chains
      code        = "tmux has-session -t opencode 2>/dev/null; and echo '🤖 OpenCode is already active! Logs: tmux a -t opencode'; or tmux new-session -d -s opencode 'nix run github:sircam-html/opencode-sandbox --override-input nixpkgs nixpkgs'; or echo '❌ Failed to start session.'; and echo '🚀 OpenCode spawned! Refresh Zen at http://127.0.0.1:8642'";
      # Force kill the background OpenCode web server engine and immediately free up system RAM memory
      code-kill   = "tmux kill-session -t opencode && echo '🧹 OpenCode background web engine has been completely stopped!'";
      # Factory reset to instantly wipe your OpenCode database, code histories, and caches
      code-wipe   = "tmux kill-session -t opencode 2>/dev/null; rm -rf ~/.cache/opencode-sandbox && echo '💥 OpenCode workspace cache has been completely wiped back to a factory-clean slate!'";
    };
  };

}
