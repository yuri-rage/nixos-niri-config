# remote Nix flake
#
#  remote access, mesh networking, and remote desktop tools
#
# provides:
#   - system: tailscale service + firewall rules, proton-vpn, rustdesk-flutter desktop client
#
# required artifacts:
#   - (none)

{ ... }:
{
  flake.nixosModules.remote =
    { pkgs, ... }:
    {
      # Tailscale mesh VPN daemon
      services.tailscale = {
        enable = true;
        openFirewall = true;
        extraSetFlags = [ "--operator=yuri" ];
      };

      # Trust Tailscale interface so tailnet peers can reach host services
      networking.firewall.trustedInterfaces = [ "tailscale0" ];

      # Proton VPN & RustDesk desktop clients
      environment.systemPackages = with pkgs; [
        proton-vpn
        rustdesk-flutter
      ];
    };
}
