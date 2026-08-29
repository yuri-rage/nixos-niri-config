# rage-nix hardware configuration
#
#  kernel modules, qemu guest agent, SCSI generic optical support, and physical filesystems
#
# provides:
#   - system: nixosModules.rageHardware (qemuGuest, latest kernel, optical SCSI sg module, fileSystems)
#
# required artifacts:
#   - (none)

{ ... }:
{
  flake.nixosModules.rageHardware =
    {
      pkgs,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
      ];

      # QEMU Guest Agent for Proxmox VE
      services.qemuGuest.enable = true;

      # Use latest kernel and SCSI Generic module for optical drives / MakeMKV
      boot.kernelPackages = pkgs.linuxPackages_latest;
      boot.kernelModules = [
        "kvm-amd"
        "sg"
      ];
      boot.supportedFilesystems = [ "nfs" ];

      boot.initrd.availableKernelModules = [
        "uhci_hcd"
        "ehci_pci"
        "ahci"
        "virtio_pci"
        "virtio_scsi"
        "sd_mod"
        "sr_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/2b3dd428-24a9-4843-ab2a-4b1b0e08b5fe";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/5BDA-AED7";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [ ];

      # Display EDID Firmware
      hardware.firmware = [
        (pkgs.runCommand "edid-mag341cq" { } ''
          mkdir -p $out/lib/firmware/edid
          cp ${./mag341cq.bin} $out/lib/firmware/edid/mag341cq.bin
        '')
      ];

      boot.kernelParams = [
        "console=tty0"
        "console=ttyS0,115200"
        "video=DP-1:e"
        "drm.edid_firmware=DP-1:edid/mag341cq.bin"
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
