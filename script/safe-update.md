# 🛡️ Hydra Pre-Update Verifier (`safe-update`)

A high-performance, fully declarative NixOS and Home Manager update shield designed to guarantee system stability. This script acts as an intelligent safety gate: it dynamically audits an installed environment, cross-references it with upstream **Hydra build servers**, and aborts the update sequence if any critical package update is broken or unbuilt upstream.

## 🚀 Key Features & Architectural Enhancements

*   **⚡ Instant Profile Auditing (\(O(1)\) Complexity):** Replaced slow, global network tree evaluations (`nix-env -qaP`) with localized link-parsing directly from `/run/current-system/sw`. Profile fetching was reduced from **minutes to milliseconds**.
*   **🔮 Dynamic Unfree Detection:** Completely eliminated the need for hardcoded package exception arrays. The script leverages `nix-instantiate` to evaluate a configuration's `allowUnfreePredicate` in real-time, adapting automatically when you add or remove unfree software.
*   **🫧 Zero False Positives:** Built-in RegEx filters purge internal environment shell noise (such as Fish shell's `hm-session-vars.fish` and manual page structures) to ensure only valid user-facing applications are queried.
*   **🎯 Smart Package Translation:** Automatically intercepts generic user names for suite packages (e.g., mapping `kcalc`, `yakuake`, or `ktorrent` to `kdePackages.*`) ensuring `hydra-check` correctly maps upstream attribute paths without orphan errors.
*   **❄️ Zero-Clutter Execution Bubble:** Users do not need to rewrite their configurations or turn their dotfiles into a Flake. Running via `nix run` streams the dependency bytecode directly inside a secure environment bubble, clearing out of memory upon execution.

---

## 🛠️ How It Works Under the Hood

```text
STEP 1: [Local Audit]
        └──> Dynamically extracts all system packages & Home Manager profiles.

STEP 2: [Dynamic Sync]
        └──> Evaluates allowed unfree apps & maps proper Hydra paths.

STEP 3: [Hydra Query]
        └──> Checks status for ALL your unique packages on 26.05.
             │
             ├──> [❌ FAILED] ──> Abort Update! (Protects system state)
             └──> [✅ GREEN]  ──> Running update... (Executes Upgrade Sequence)
```

---

## 🚀 Instant Installation & Usage

No configuration editing required. You can evaluate your system against the Hydra builder pools immediately by targeting the repository stream directly:

```fish
nix run github:sircam-html/nixos-conf
```

*This command clones the portable module wrapper, builds a transient sandbox binary, executes the pre-flight safety audit, and cleans itself up completely when finished.*

---

## 📋 Recommended Complementary Deep Cleaning

To completely flush out old generation nodes and reclaim massive amounts of NVMe space 24–48 hours after your monthly upgrade, execute these commands sequentially in your terminal:

```bash
# 1. Collect user-level garbage
nix-collect-garbage -d

# 2. Collect system-level garbage 
sudo nix-collect-garbage -d

# 3. Purge old system boot entries and refresh bootloader profile
sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations old
sudo nixos-rebuild boot

# 4. Optimize the Nix store by hardlinking duplicate files
nix-store --optimise
```

**Why This Exact Order Matters:** Deleting the old boot configurations explicitly breaks structural links to legacy dependencies. Once those old nodes are unlinked from the system profile, the garbage collectors (Steps 1 & 2) wipe them completely, allowing `--optimise` (Step 4) to clean and deduplicate the remaining files.

---

## 🏆 Summary of Advantages

1.  **Absolute Immune System:** Avoids broken builds entirely by checking server health before touching local dependencies.
2.  **Zero-Maintenance overhead:** Adapts automatically whenever you add, change, or remove software profiles.
3.  **Maximum NVMe Efficiency:** Paired with a deep-clean schedule, it allows massive space recovery sessions by safely flushing out old generation nodes.
