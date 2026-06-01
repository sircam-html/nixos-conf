# NixOS Configurations

Personal NixOS setup backup for reproducibility **Stable 25.11, 26.05 and Unstable** with KDE Plasma 6 on a hybrid AMD/NVIDIA system.




# 🛡️ Hydra Pre-Update Verifier (`safe-update`)

A high-performance update shield for NixOS and Home Manager that checks the build status of your unique packages on upstream **Hydra build servers** before allowing an upgrade. If any critical package update is broken or unbuilt upstream, it immediately aborts the sequence to protect your system state.

---

## 🚀 How to Run It (Instant & Portable)

No configuration editing or dotfile rewriting required. You can evaluate your system against the Hydra builder pools immediately by streaming the sandbox module directly from this repository:

```fish
nix run github:sircam-html/nixos-conf
```

*This command clones the portable flake module wrapper, builds a transient sandbox binary, executes the pre-flight safety audit across your System + Home Manager profiles, and completely flushes itself out of memory when finished.*

---

## 🧠 What It Does Under the Hood

1. **⚡ Millisecond Audit:** Replaced slow network tree evaluations (`nix-env -qaP`) with localized link-parsing directly from `/run/current-system/sw` to fetch your active packages in milliseconds.
2. **🔮 Live Unfree Detection:** Queries `nix-instantiate` to read your allowed unfree applications dynamically in real-time—no hardcoded lists needed.
3. **🎯 Smart Suite Translation:** Intercepts generic suite apps (like `kcalc` or `yakuake`) and translates them to their proper attribute paths (`kdePackages.*`) so `hydra-check` never throws orphan errors.
4. **🫧 Zero Clutter:** Automatically filters out internal environment noise (like Fish shell's `hm-session-vars.fish`) to guarantee zero false positives.

---

## 🏆 Summary of Advantages

* **Absolute Immune System:** Avoids broken builds entirely by checking server health before touching local dependencies.
* **Zero Maintenance overhead:** Adapts automatically whenever you add, change, or remove software profiles.
* **Study & Modify:** Feel free to fork this logic, optimize it, or implement it natively into your own declarative setups!

