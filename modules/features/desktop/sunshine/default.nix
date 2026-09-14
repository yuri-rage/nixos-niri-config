# sunshine Nix flake
#
#  low-latency game streaming server and KMS display capture
#
# provides:
#   - system: sunshine service (KMS capture + firewall) + uinput virtual input subsystem
#
# required artifacts:
#   - (none)

{ ... }:
{
  flake.nixosModules.sunshine =
    { pkgs, lib, ... }:
    {
      # virtual input device subsystem for Sunshine mouse, keyboard & gamepad emulation
      hardware.uinput.enable = true;

      # Grant cap_sys_admin (KMS capture) and cap_sys_nice (real-time EGL scheduling priority)
      security.wrappers.sunshine.capabilities = lib.mkForce "cap_sys_admin,cap_sys_nice+p";

      services.sunshine = {
        enable = true;
        autoStart = true;
        package = pkgs.sunshine.override { cudaSupport = true; };
        # capSysAdmin is required for direct KMS/DRM framebuffer capture on Wayland without running as root
        capSysAdmin = true;
        openFirewall = true;
      };
    };
}
