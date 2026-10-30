# rust Nix flake
#
#  system-wide Rust development toolchain, compiler, linter, formatter, and language server
#
# provides:
#   - system: rustc, cargo, clippy, rustfmt, rust-analyzer, gcc, pkg-config
#
# required artifacts:
#   - (none)

{ ... }:
{
  flake.nixosModules.rust =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # Core Rust toolchain
        rustc
        cargo

        # Code quality & formatting
        clippy
        rustfmt

        # Language Server Protocol (LSP)
        rust-analyzer

        # Build prerequisites for crates with C/native extensions
        gcc
        pkg-config
      ];

      # Ensure cargo binaries in ~/.cargo/bin are discoverable if user installs crates via cargo install
      environment.sessionVariables = {
        CARGO_HOME = "$HOME/.cargo";
        RUSTUP_HOME = "$HOME/.rustup";
      };
    };
}
