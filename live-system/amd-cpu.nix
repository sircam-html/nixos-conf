# ── AMD CPU Management ────────────────────────────────────────────────────────
{ config, pkgs, ... }:

{
  # ── AMD CPU Microcode ─────────────────────────────────────────────────────────
  hardware.cpu.amd.updateMicrocode = true;

  # ── TLP Power Management ──────────────────────────────────────────────────────
  services.tlp.enable = true;
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_AC   = "schedutil";
    CPU_BOOST_ON_AC              = 0;
    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
  };

  # ── Disable power-profiles-daemon ─────────────────────────────────────────────
  services.power-profiles-daemon.enable = false;

  # ── Power Management ──────────────────────────────────────────────────────────
  powerManagement.enable          = true;
  powerManagement.cpuFreqGovernor = null;

  # ── Disable Sleep / Hibernation ───────────────────────────────────────────────
  systemd.sleep.settings.Sleep = {
    AllowSuspend              = "no";
    AllowHibernation          = "no";
    AllowHybridSleep          = "no";
    AllowSuspendThenHibernate = "no";
  };
}
