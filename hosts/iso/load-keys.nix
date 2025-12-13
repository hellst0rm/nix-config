# hosts/iso/load-keys.nix
# Ventoy key injection support - keys are injected into initramfs by Ventoy bootloader
{
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.load-keys ];

  boot = {
    initrd = {
      # Virtio support for QEMU testing with Ventoy disk
      kernelModules = [
        "virtio_blk"
        "virtio_pci"
      ];
      availableKernelModules = [
        "virtio_blk"
        "virtio_pci"
      ];

      # Make load-keys utility available in initrd
      extraUtilsCommands = ''
        copy_bin_and_libs ${pkgs.load-keys}/bin/load-keys
      '';

      # Load Ventoy-injected keys during initramfs (stage 1) - BEFORE sops-nix runs
      # Ventoy extracts keys.tar.gz into initramfs root before boot
      postMountCommands = ''
        echo "=== Stage 1: Loading SSH keys (Ventoy) ==="

        # Check for Ventoy-injected host key (primary indicator)
        if [ -f /etc/ssh/ssh_host_ed25519_key ]; then
          echo "Found Ventoy-injected keys, copying to target..."
          ${pkgs.load-keys}/bin/load-keys / $targetRoot
        else
          echo "No Ventoy-injected keys found (expected: /etc/ssh/ssh_host_ed25519_key)"
        fi

        echo "=== Stage 1: Key loading complete ==="
      '';
    };

    # Override installation-cd-minimal.nix defaults
    postBootCommands = lib.mkForce "";
  };
}
