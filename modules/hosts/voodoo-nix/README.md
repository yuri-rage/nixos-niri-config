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
Download the latest `nixos.wsl` from [NixOS-WSL Releases](https://github.com/nix-community/NixOS-WSL/releases) and install it with the custom name `voodoo-nix` from Windows PowerShell:

```powershell
wsl --install --from-file .\nixos.wsl --name voodoo-nix
```
*Windows will install the distribution and automatically drop you directly into the new instance at the `nixos` shell prompt.*

### 2. Provision Secret Keys
`sops-nix` runs during system activation and requires the host private key to decrypt secrets (`smb-credentials`, `ssh-hosts`, etc.). Copy the SSH host key into place before building:

```bash
# Copy the host private SSH key (matching host_voodoo in .sops.yaml) from Windows:
sudo cp /mnt/c/path/to/ssh_host_ed25519_key /etc/ssh/ssh_host_ed25519_key
sudo chmod 600 /etc/ssh/ssh_host_ed25519_key
```

### 3. Clone Repository
From the active prompt inside the instance, clone the repository via an ephemeral `nix-shell`:
```bash
nix-shell -p git --run "git clone https://github.com/yuri-rage/nixos-niri-config.git ~/nixcfg"
```

### 4. Initial System Bootstrap
Build and activate the initial NixOS system configuration directly referencing the `nixcfg` flake:
```bash
sudo nixos-rebuild switch --flake ~/nixcfg#voodoo-nix
```
*This build declaratively creates the `yuri` user and `/home/yuri`, decrypts secrets via `sops-nix`, sets `wsl.defaultUser = "yuri"` for Windows autologin, sets the hostname to `voodoo-nix`, and installs `home-manager`.*

### 5. Move Repository to `/home/yuri`
Relocate the cloned repository into `yuri`'s newly created home directory and transfer ownership:
```bash
sudo mv ~/nixcfg /home/yuri/nixcfg
sudo chown -R yuri:users /home/yuri/nixcfg
```

### 6. Restart WSL Session
Exit the session and restart the distribution from Windows PowerShell to apply the new default user:
```powershell
exit
wsl -t voodoo-nix
wsl -d voodoo-nix
```
*WSL will now automatically log in directly as `yuri@voodoo-nix` in `/home/yuri`.*

### 7. Clean Up `nixos` & Activate Home Manager
Now inside WSL as `yuri`:
```bash
# Remove leftover installer home directory and account:
sudo rm -rf /home/nixos
sudo userdel nixos

# (Optional) Provision user Age key for SOPS CLI / 'j secrets' editing:
mkdir -p ~/.config/sops/age
cp /mnt/c/path/to/keys.txt ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# Build and activate the initial Home Manager configuration:
cd ~/nixcfg
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
