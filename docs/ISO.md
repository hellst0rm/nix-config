# NixOS ISO Configuration

Minimal NixOS installation ISO with Ventoy boot and SSH key injection.

## Features

- **Pure Nix build** - No `--impure` flag required
- **UEFI bootable** - Works with modern UEFI systems
- **Ventoy boot** - Keys injected automatically during boot
- **Persistent SSH keys** - Load keys from nix-keys repository

## Quick Start

```bash
# Enter development shell
nix develop

# Build ISO + Ventoy disk (requires Yubikey)
iso build

# Run in QEMU
iso run

# SSH into guest
iso ssh

# Stop QEMU
iso stop
```

## Commands

| Command | Description |
|---------|-------------|
| `iso build` | Build ISO + Ventoy disk with key injection |
| `iso rebuild` | Force rebuild (ignore cache) |
| `iso run` | Boot Ventoy disk in QEMU |
| `iso stop` | Stop QEMU |
| `iso restart` | Restart QEMU |
| `iso status` | Check if QEMU is running |
| `iso ssh` | SSH into running guest |
| `iso log` | View serial output |
| `iso path` | Print ISO path in nix store |
| `iso copy` | Copy ISO out of nix store |

## Key Injection

Keys are managed through the **nix-keys** repository and injected via Ventoy's injection feature.

### Ventoy Disk Structure

```
Ventoy partition:
├── nixos.iso           # NixOS installation ISO
├── keys.tar.gz         # Key injection archive
└── ventoy/
    └── ventoy.json     # Injection configuration
```

### Injected Key Structure

Ventoy extracts `keys.tar.gz` into the initramfs during boot:

```
etc/ssh/
├── ssh_host_ed25519_key      # Host private key
└── ssh_host_ed25519_key.pub  # Host public key
root/.ssh/
├── deploy_key_ed25519        # Deploy private key
└── deploy_key_ed25519.pub    # Deploy public key
users/<user>/.ssh/
├── id_ed25519                # User private key
└── id_ed25519.pub            # User public key
```

### Build Options

```bash
# Host keys only (default)
iso build

# Include specific user keys
iso build -U rona

# Use different host's keys
iso build -H nanoserver

# Custom nix-keys location
iso build --keys-repo /path/to/nix-keys
```

## Boot Process

1. QEMU boots from Ventoy disk
2. Ventoy bootloader loads `nixos.iso`
3. Ventoy injects `keys.tar.gz` contents into initramfs
4. NixOS initramfs (stage 1) runs `postMountCommands`
5. `load-keys` utility copies keys from `/` to `$targetRoot`
6. System boots with SSH keys in place
7. sops-nix decrypts secrets using host key

### Why Stage 1?

- Keys available before system services start
- Works with sops-nix (needs host keys for decryption)
- SSH service starts with proper keys immediately
- No timing issues or race conditions

## Configuration Files

| File | Purpose |
|------|---------|
| `default.nix` | Main ISO configuration |
| `load-keys.nix` | Ventoy key injection handling |
| `ssh.nix` | SSH service configuration |
| `boot.nix` | Boot configuration |
| `network.nix` | Network configuration |
| `users.nix` | User accounts |
| `programs.nix` | Additional programs |
| `tailscale.nix` | Tailscale VPN setup |

## load-keys Utility

The `load-keys` utility (`pkgs/load-keys.nix`) handles SSH key copying:

```bash
load-keys <source_dir> [target_root]

# Ventoy initramfs usage:
load-keys / $targetRoot
```

Automatically detects and loads:
- SSH host keys from `<source>/etc/ssh/`
- Deploy keys from `<source>/root/.ssh/`
- User keys from `<source>/users/*/.ssh/`

## Troubleshooting

### No Keys Found

Check serial log during boot:
```bash
iso log
```

Expected output with keys:
```
=== Stage 1: Loading SSH keys (Ventoy) ===
Found Ventoy-injected keys, copying to target...
=== Stage 1: Key loading complete ===
```

Without keys:
```
=== Stage 1: Loading SSH keys (Ventoy) ===
No Ventoy-injected keys found (expected: /etc/ssh/ssh_host_ed25519_key)
=== Stage 1: Key loading complete ===
```

### Verify Ventoy Disk

```bash
# Check disk was created
ls -la /tmp/*-ventoy.img

# Rebuild if needed
iso rebuild
```

### SSH Connection Issues

```bash
# Check QEMU is running
iso status

# View logs for errors
iso log

# Try with verbose SSH
ssh -v -p 2222 rona@localhost
```
