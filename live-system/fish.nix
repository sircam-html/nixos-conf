{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    functions = {
      lazy-push = ''
        git add .
        git commit -m "$argv"
        git push origin main
      '';

      backup = ''
        set -l REPO "$HOME/nixos-conf"
        set -l DEST "live-system"
        set -l MSG $argv[1]

        if test -z "$MSG"
          set MSG "sync: $(date '+%Y-%m-%d %H:%M')"
        end

        if test ! -d "$REPO"
          git clone https://github.com/sircam-html/nixos-conf.git "$REPO"
          or echo "❌ Clone failed"; return 1
        end

        mkdir -p "$REPO/$DEST"

        if not cp ~/.config/home-manager/home.nix "$REPO/$DEST/"
          echo "❌ home.nix copy failed"; return 1
        end
        if not cp ~/.config/home-manager/fish.nix "$REPO/$DEST/"
          echo "❌ fish.nix copy failed"; return 1
        end
        if not cp /etc/nixos/nvidia.nix "$REPO/$DEST/"
          echo "❌ nvidia.nix copy failed"; return 1
        end
        if not cp /etc/nixos/configuration.nix "$REPO/$DEST/"
          echo "❌ configuration.nix copy failed"; return 1
        end

        cd "$REPO"
        if test (count (git status --porcelain)) -ge 1
          git add -A
          git commit -m "$MSG"
          git push origin main
          echo "✓ Configs backed up to GitHub"
        else
          echo "✓ No changes — already up to date"
        end
      '';
    };

    shellAliases = {
      bu          = "backup";
      safe-check  = "nix run github:sircam-html/safe-update-nix -- --check";
      safe-update = "nix run github:sircam-html/safe-update-nix";
      update      = "sudo nix-channel --update && sudo nixos-rebuild switch --upgrade && home-manager switch";
      trim        = "nix-collect-garbage -d && sudo nix-collect-garbage -d && sudo nix-env --delete-generations old && sudo nixos-rebuild boot && home-manager expire-generations '2 weeks ago' && nix store optimise";
      hm          = "home-manager switch";
      nr          = "sudo nixos-rebuild switch";
      nn          = "kate /etc/nixos/nvidia.nix";
      fn          = "kate ~/.config/home-manager/fish.nix";
      cn          = "kate /etc/nixos/configuration.nix";
      hn          = "kate ~/.config/home-manager/home.nix";
      gc          = "nix-collect-garbage -d && sudo nix-collect-garbage -d";
      dg          = "sudo nix-env --delete-generations old && sudo nixos-rebuild boot";
      op          = "nix store optimise";
      ps          = "systemctl --user restart plasma-plasmashell";
      ff          = "fastfetch -c examples/25";
      ch          = "sudo nix-channel --list && echo '───' && nix-channel --list";
      ver         = "nixos-version && nixos-version --revision && home-manager --version";
      hc          = "hydra-check";
      servers     = "cd /home/sircam/_devbox/ && devbox run caddy run --config Caddyfile";
      chrome      = "nix run github:sircam-html/chrome-sandbox";
      chrome-wipe = "rm -rf ~/.cache/chrome-sandbox && echo '🧹 Chrome sandbox has been completely wiped!'";
      code        = "tmux has-session -t opencode 2>/dev/null; and echo '🤖 OpenCode is already active! Logs: tmux a -t opencode'; or tmux new-session -d -s opencode 'nix run github:sircam-html/opencode-sandbox'; or echo '❌ Failed to start session.'; and echo '🚀 OpenCode spawned! Refresh Zen at http://127.0.0.1:8642'";
      code-kill   = "tmux kill-session -t opencode && echo '🧹 OpenCode background web engine has been completely stopped!'";
      code-wipe   = "tmux kill-session -t opencode 2>/dev/null; rm -rf ~/.cache/opencode-sandbox && echo '💥 OpenCode workspace cache has been completely wiped back to a factory-clean slate!'";
    };
  };
}
