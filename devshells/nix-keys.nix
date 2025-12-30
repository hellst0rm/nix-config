# devshells/nix-keys.nix
# SSH/GPG keys management shell
{
  pkgs,
  mkProjectShell,
  ...
}:
mkProjectShell {
  name = "nix-keys";

  motd = ''
    ╔════════════════════════════════════════════╗
    ║  Nix Keys Management Shell                ║
    ╚════════════════════════════════════════════╝

    SSH and GPG key management.

    Commands:
      list-ssh              List SSH keys
      list-gpg              List GPG keys
      menu                  Show all commands
  '';

  packages = with pkgs; [
    gnupg
    openssh
    age
    ssh-to-age
  ];

  commands = [
    {
      name = "list-ssh";
      category = "keys";
      help = "List SSH public keys";
      command = ''
        for f in *.pub; do
          [ -f "$f" ] && echo "=== $f ===" && cat "$f" && echo
        done
      '';
    }
    {
      name = "list-gpg";
      category = "keys";
      help = "List GPG keys";
      command = "gpg --list-keys";
    }
    {
      name = "ssh-to-age";
      category = "keys";
      help = "Convert SSH key to age key";
      command = ''
        if [ -z "$1" ]; then
          echo "Usage: ssh-to-age <ssh-public-key-file>"
          exit 1
        fi
        ssh-to-age -i "$1"
      '';
    }
  ];
}
