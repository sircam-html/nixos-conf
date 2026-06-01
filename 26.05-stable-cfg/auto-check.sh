#!/usr/bin/env bash
# auto-check.sh — checks ALL Home Manager packages on Hydra
CHANNEL="26.05"
FAILED=0

packages=$(nix-store -q --requisites ~/.local/state/nix/profiles/home-manager | \
  xargs -I{} nix-store -q --name {} 2>/dev/null | \
  grep -v "^$" | sort -u)

echo "🔍 Checking ALL Home Manager packages on nixos-$CHANNEL..."
echo "─────────────────────────────────────────────────"

for pkg in $packages; do
  result=$(hydra-check "$pkg" --channel "$CHANNEL" 2>/dev/null | grep -E "✔|✖")
  if echo "$result" | grep -q "✖"; then
    echo "❌ $pkg → FAILED"
    FAILED=1
  elif echo "$result" | grep -q "✔"; then
    echo "✅ $pkg → OK"
  fi
done

echo "─────────────────────────────────────────────────"
if [ $FAILED -eq 1 ]; then
  echo "❌ Some packages failed!"
else
  echo "✅ All packages green!"
fi
