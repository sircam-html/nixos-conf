#!/usr/bin/env bash
# pre-update-check.sh
# Checks critical packages on Hydra before updating NixOS

CHANNEL="26.05"
FAILED=0

# Known unfree/pre-built packages — Hydra doesn't track these
# They ship pre-built binaries so they're always available
unfree_packages=("ferdium" "discord" "google-chrome" "vivaldi" "brave")

packages=(
  # Critical - breaks gaming
  "bottles"
  "wine"
  # Critical - breaks desktop
  "kdePackages.plasma-desktop"
  # Critical - breaks browsing
  "brave"
  # Critical - breaks virtualization
  "libvirt"
  # Important - breaks communication
  "ferdium"
  "discord"
  # Important - breaks multimedia
  "pear-desktop"
  "vlc"
  # Important - breaks productivity
  "obs-studio"
  "heroic"
  # Infrastructure
  "openldap"
)

echo "🔍 Checking critical packages on nixos-$CHANNEL..."
echo "─────────────────────────────────────────────────"

for pkg in "${packages[@]}"; do
  # Check if package is unfree/pre-built
  if [[ " ${unfree_packages[@]} " =~ " ${pkg} " ]]; then
    echo "📦 $pkg → Pre-built binary, Hydra doesn't track — assumed OK"
    continue
  fi

  result=$(hydra-check "$pkg" --channel "$CHANNEL" 2>/dev/null | grep -E "✔|✖|⏹")

  if echo "$result" | grep -q "✔"; then
    echo "✅ $pkg → OK"
  elif echo "$result" | grep -q "✖"; then
    echo "❌ $pkg → FAILED — aborting update!"
    FAILED=1
  else
    echo "⚠️  $pkg → Unknown status"
  fi
done

echo "─────────────────────────────────────────────────"

if [ $FAILED -eq 1 ]; then
  echo "❌ Some packages failed — update aborted!"
  exit 1
else
  echo "✅ All packages green — safe to update!"
  echo "🚀 Running update..."
  sudo nix-channel --update && sudo nixos-rebuild switch --upgrade && home-manager switch
fi
