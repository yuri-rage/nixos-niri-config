nixcfg_dir := env('HOME') / 'nixcfg'
host := `hostname -s`
user := `whoami`

# Display available recipes
default:
    @just --list

# Ensure all files are formatted and tracked by git for Nix evaluation
[private]
stage:
    @nix fmt {{ nixcfg_dir }} >/dev/null 2>&1 || true
    @git -C {{ nixcfg_dir }} add -N . 2>/dev/null || true

# Format all Nix files in repository
fmt:
    nix fmt {{ nixcfg_dir }}

# Edit encrypted sops secrets file
secrets:
    @nix-shell -p sops --run "sops {{ nixcfg_dir }}/secrets/secrets.yaml"

# Rebuild & switch system and home (NixOS system first, then Home Manager)
switch host=host user=user: stage
    @echo "=== Activating NixOS System ({{ host }}) ==="
    sudo nixos-rebuild switch --flake {{ nixcfg_dir }}#{{ host }}
    @echo "=== Activating Home Manager ({{ user }}) ==="
    home-manager switch --flake {{ nixcfg_dir }}#{{ user }}

# Rebuild & switch NixOS system
switch-host host=host: stage
    sudo nixos-rebuild switch --flake {{ nixcfg_dir }}#{{ host }}

# Rebuild & switch Home Manager
switch-home user=user: stage
    home-manager switch --flake {{ nixcfg_dir }}#{{ user }}

# Dry-build system and home configurations
build host=host user=user: stage
    @echo "Building Home Manager for {{ user }}..."
    home-manager build --no-out-link --flake {{ nixcfg_dir }}#{{ user }}
    @echo "Building NixOS System for {{ host }}..."
    nixos-rebuild build --no-link --flake {{ nixcfg_dir }}#{{ host }}
    @echo "Build successful!"

# Show package diff between current system/home and new build
diff host=host user=user: stage
    #!/usr/bin/env bash
    set -euo pipefail
    echo "=== Home Manager Closure Diff ({{ user }}) ==="
    current_hm=$(readlink -f ~/.local/state/nix/profiles/home-manager 2>/dev/null || readlink -f /nix/var/nix/profiles/per-user/{{ user }}/home-manager || true)
    new_hm=$(nix build {{ nixcfg_dir }}#homeConfigurations.{{ user }}.activationPackage --no-link --print-out-paths)
    if [[ -n "$current_hm" && -n "$new_hm" ]]; then
        nix store diff-closures "$current_hm" "$new_hm" || true
    fi
    echo ""
    echo "=== NixOS System Closure Diff ({{ host }}) ==="
    nixos-rebuild build --diff --no-link --flake {{ nixcfg_dir }}#{{ host }}

# Validate flake outputs and syntax
check: stage
    @cd {{ nixcfg_dir }} && \
      broken=$(grep -rhoP '\blink "\K[^"]+' modules | sort -u | while read -r p; do \
        test -e "$p" || echo "$p"; done); \
      if [ -n "$broken" ]; then echo "broken link targets:"; echo "$broken"; exit 1; fi
    @echo "link targets OK"
    nix flake check {{ nixcfg_dir }} --no-build

# Update flake inputs
update *args:
    nix flake update {{ args }} --flake {{ nixcfg_dir }}

# Update flake inputs and switch system + home
update-switch *args: (update args) switch

# List system & user generations
history:
    @echo "=== NixOS System Generations ==="
    @nixos-rebuild list-generations
    @echo ""
    @echo "=== Home Manager Generations ==="
    @home-manager generations

# Clean old generations (keeps 7d, or pass custom e.g. '30d' / 'all')
gc scope="7d":
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ "{{ scope }}" == "all" ]]; then
        echo "Purging all previous generations..."
        nix-collect-garbage -d
        sudo nix-collect-garbage -d
    else
        echo "Collecting garbage older than {{ scope }}..."
        nix-collect-garbage --delete-older-than "{{ scope }}"
        sudo nix-collect-garbage --delete-older-than "{{ scope }}"
    fi
    sudo /run/current-system/bin/switch-to-configuration boot

# Deduplicate store hard links
optimise:
    nix store optimise

# Search packages on search.nixos.org
search *query:
    xdg-open "https://search.nixos.org/packages?channel=unstable&query={{ query }}"

# Search NixOS options on search.nixos.org
search-options *query:
    xdg-open "https://search.nixos.org/options?channel=unstable&query={{ query }}"

# Deploy SSH public key to remote host
ssh-copy-id target *args:
    ssh-copy-id -i ~/.ssh/id_ed25519.pub {{ args }} {{ target }}
