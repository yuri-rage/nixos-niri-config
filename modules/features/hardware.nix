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
        nvtopPackages.nvidia
      ];

      # NVIDIA GPU & Graphics Acceleration
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.enableRedistributableFirmware = true;
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      hardware.nvidia = {
        modesetting.enable = true;
        open = true; # Open-source kernel modules (GSP firmware), supported on modern kernels
        powerManagement.enable = false;
        nvidiaSettings = false; # Headless / pure Wayland clean
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
