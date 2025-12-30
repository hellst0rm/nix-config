# devshells/nix-secrets.nix
# Secrets management shell (sops-nix)
{
  pkgs,
  mkProjectShell,
  ...
}:
mkProjectShell {
  name = "nix-secrets";

  motd = ''
    ╔════════════════════════════════════════════╗
    ║  Nix Secrets Management Shell             ║
    ╚════════════════════════════════════════════╝

    Encrypted secrets with sops-nix.

    Commands:
      edit                  Edit secrets file
      rotate                Re-encrypt all secrets
      menu                  Show all commands
  '';

  packages = with pkgs; [
    sops
    age
    ssh-to-age
  ];

  commands = [
    {
      name = "edit";
      category = "secrets";
      help = "Edit a secrets file: edit <file.yaml>";
      command = ''
        if [ -z "$1" ]; then
          echo "Usage: edit <secrets-file.yaml>"
          exit 1
        fi
        sops "$1"
      '';
    }
    {
      name = "rotate";
      category = "secrets";
      help = "Re-encrypt all secrets with current keys";
      command = ''
        for f in *.yaml secrets/*.yaml; do
          [ -f "$f" ] && echo "Rotating: $f" && sops updatekeys -y "$f"
        done
      '';
    }
    {
      name = "decrypt";
      category = "secrets";
      help = "Decrypt a secret to stdout: decrypt <file.yaml>";
      command = ''
        if [ -z "$1" ]; then
          echo "Usage: decrypt <secrets-file.yaml>"
          exit 1
        fi
        sops -d "$1"
      '';
    }
  ];
}
