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
    { ... }:
    {
      # virtual input device subsystem for Sunshine mouse, keyboard & gamepad emulation
      hardware.uinput.enable = true;

      services.sunshine = {
        enable = true;
        autoStart = true;
        # capSysAdmin is required for direct KMS/DRM framebuffer capture on Wayland without running as root
        capSysAdmin = true;
        openFirewall = true;
      };
    };
}
