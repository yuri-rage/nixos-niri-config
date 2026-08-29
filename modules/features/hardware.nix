# hardware Nix flake
#
#  generic base hardware services, audio subsystems, and graphics drivers
#
# provides:
#   - system: pipewire audio/pulse/alsa, bluetooth, opengl, enableRedistributableFirmware
#
# required artifacts:
#   - (none)

{ ... }:
{
  flake.nixosModules.hardware =
    { pkgs, ... }:
    {
      # Hardware Diagnostic & Inspection Tools
      environment.systemPackages = with pkgs; [
        clinfo
        pciutils
      ];

      # AMD GPU & Graphics Acceleration
      hardware.enableRedistributableFirmware = true;
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          rocmPackages.clr.icd
          rocmPackages.clr
          rocmPackages.rocminfo
          libva
          libva-utils
        ];
      };

      # Realtime Audio Scheduling Priority
      security.rtkit.enable = true;

      # Audio Stack: PipeWire + Null Sink for Sunshine Streaming
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      services.pipewire.extraConfig.pipewire."99-null-sink" = {
        "context.objects" = [
          {
            factory = "adapter";
            args = {
              "factory.name" = "support.null-audio-sink";
              "node.name" = "sunshine-sink";
              "media.class" = "Audio/Sink";
              "audio.position" = "FL,FR";
            };
          }
        ];
      };
    };
}
