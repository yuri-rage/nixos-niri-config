# voodoo-nix (NixOS on WSL2)

`voodoo-nix` is the **Windows Subsystem for Linux (WSL2)** host configuration in this repository. Powered by [NixOS-WSL](https://github.com/nix-community/NixOS-WSL), it brings the same declarative, reproducible developer toolchain used on bare-metal and VM hosts into a lightweight, integrated Windows development environment.

---

## Overview & Outputs

The host composition is declared in [`modules/hosts/voodoo-nix/default.nix`](./default.nix) and [`configuration.nix`](./configuration.nix), exposing two primary flake outputs:

| Flake Output | Type | Target | Description |
| :--- | :--- | :--- | :--- |
| `nixosConfigurations.voodoo-nix` | System | Host | NixOS WSL2 base system configuration |
| `homeConfigurations."yuri@voodoo-nix"` | User | User Profile | Home Manager user environment for `yuri` |

---

## Architecture & Module Composition

`voodoo-nix` reuses the dendritic feature modules while omitting bare-metal and workstation display layers (such as Niri, Greetd, Noctalia, and Sunshine):

```text
modules/hosts/voodoo-nix/
├── default.nix          # Flake output instances (nixosConfigurations & homeConfigurations)
├── configuration.nix    # System options, WSL settings, user setup, and module imports
└── README.md            # Host documentation
```

### Included Features

* **Developer Toolchains (`dev`)**:
  * **Editors & LSPs**: Neovim (Native LSP with `tinymist`, `basedpyright`, `ruff`, `nil`, `lua-ls`), Zed editor integration.
  * **Runtimes & Tools**: Python 3, Docker, Direnv (`nix-direnv`), Git, and Antigravity CLI.
* **Shell & Terminal**:
  * Bash with Starship prompt, Bat (`cat` alias), Btop resource monitor, Fastfetch, and declarative SSH configuration.
* **Secrets Management**:
  * Declarative secret decryption via `sops-nix` using local Age keys.

---

## WSL2 Adaptations & Nuances

Because WSL2 runs within a specialized Microsoft micro-VM kernel and virtualized hypervisor container, standard bare-metal hardware and initialization services are overridden:

| Component | Bare-Metal / KVM (`rage-nix`) | WSL2 (`voodoo-nix`) | Reason |
| :--- | :--- | :--- | :--- |
| **Kernel** | Latest upstream Linux (`linuxPackages_latest`) | Microsoft WSL2 Linux Kernel | Managed directly by Windows host |
| **Bootloader** | `systemd-boot` with EFI variables | **Disabled** (`lib.mkForce false`) | WSL initializes the init process directly |
| **Networking** | NetworkManager + systemd-networkd | **WSL Virtual Network** | Managed by Windows; `networkmanager` disabled |
| **Swap & Memory** | `zramSwap` | **Host-managed** (`.wslconfig`) | Handled by Windows Hyper-V memory manager |
| **Desktop GUI** | Niri + Wayland + Sunshine/Moonlight | **Headless / Windows Terminal** | GUI not required; uses native Windows display |
| **Printing/mDNS** | CUPS & Avahi enabled | **Disabled** | Reduces memory footprint in headless dev |
| **Windows Interop**| N/A | **`wsl.interop.register = true`** | Enables launching `.exe` binaries from bash |

### Git Safe Directory
Because Windows and WSL filesystems may map user IDs differently, git safe directory enforcement is declared in configuration:
```nix
programs.git.config.safe.directory = "/home/yuri/nixcfg";
```

---

## Provisioning & Setup on Windows

### 1. Install NixOS-WSL
Download the latest `nixos-wsl.tar.gz` from [NixOS-WSL Releases](https://github.com/nix-community/NixOS-WSL/releases) and import it into WSL:
```powershell
# From Windows PowerShell:
wsl --import voodoo-nix C:\WSL\voodoo-nix .\nixos-wsl.tar.gz --version 2
```

### 2. Rename Default User & Home Directory
Launch the new instance as `root` so the default `nixos` user (UID 1000) can be cleanly renamed to `yuri` without active process locks:
```powershell
# Enter as root from Windows PowerShell:
wsl -d voodoo-nix -u root
```
Inside the container as root:
```bash
# Rename the default installer user (UID 1000) and its primary group to yuri:
usermod -l yuri -d /home/yuri -m nixos
groupmod -n yuri nixos
```
*Renaming retains UID 1000 (consistent with `rage-nix`), automatically moves `/home/nixos` to `/home/yuri`, preserves file permissions, and avoids leftover accounts.*

### 3. Clone Repository
Still inside the container as root, clone the repository into `yuri`'s home using an ephemeral `nix-shell`:
```bash
su - yuri -c "nix-shell -p git --run 'git clone https://github.com/yuri-rage/nixcfg.git ~/nixcfg'"
```

### 4. Initial System Bootstrap
Build and activate the initial NixOS system configuration directly referencing the `nixcfg` flake:
```bash
nixos-rebuild switch --flake /home/yuri/nixcfg#voodoo-nix
```
*This initial build configures `wsl.defaultUser = "yuri"` (ensuring smooth Windows autologin), sets `networking.hostName = "voodoo-nix"`, and provisions the system packages including `home-manager`.*

### 5. Restart WSL Session
Exit the root shell and restart the instance from PowerShell to apply the autologin default user:
```powershell
# Exit root shell:
exit

# Terminate and relaunch from Windows PowerShell:
wsl -t voodoo-nix
wsl -d voodoo-nix
```
WSL will now automatically log in directly as `yuri@voodoo-nix` in `/home/yuri`.

### 6. Provision Secrets & Activate Home Manager
Now inside WSL as `yuri`:
```bash
cd ~/nixcfg

# Provision the age key for SOPS decryption (if using encrypted secrets):
mkdir -p ~/.config/sops/age
# Copy your age key into ~/.config/sops/age/keys.txt

# Build and activate the initial Home Manager configuration:
home-manager switch --flake ~/nixcfg#yuri@voodoo-nix

# Reload your shell to source the newly generated aliases and completions:
exec bash
```
Activating Home Manager deploys `just`, links `~/.config/just/justfile` to `~/nixcfg/justfile`, and sets up the `j` CLI wrapper with tab completions.

---

## Daily Management (`just` / `j`)

Once the initial bootstrap is complete, all daily workflow and rebuilds use the unified `j` runner (which automatically detects `voodoo-nix` and `yuri@voodoo-nix`):

```bash
j switch         # Rebuild and activate both NixOS system and Home Manager
j switch-host    # Rebuild system only (sudo nixos-rebuild switch --flake .#voodoo-nix)
j switch-home    # Rebuild Home Manager only (home-manager switch --flake .#yuri@voodoo-nix)
j diff           # Preview closure package diff before switching
j update-switch  # Update flake lockfile inputs and immediately rebuild
j gc             # Collect garbage and trim old generations (keeps 7 days)
```

---

*Return to the [Main Configuration README](../../README.md).*
