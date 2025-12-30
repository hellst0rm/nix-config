# devshells/nix-repos.nix
# Meta-repository workspace shell
{
  pkgs,
  mkProjectShell,
  ...
}:
mkProjectShell {
  name = "nix-repos";

  motd = ''
    ╔════════════════════════════════════════════╗
    ║  Nix Repos Workspace                       ║
    ╚════════════════════════════════════════════╝

    Subprojects: nix-config, nix-lib, nix-keys, nix-secrets

    Commands:
      status                Show git status across all repos
      pull                  Pull all repos
      menu                  Show all commands
  '';

  packages = with pkgs; [
    nh
    nix-diff
    gnumake
  ];

  commands = [
    {
      name = "status";
      category = "workspace";
      help = "Show git status across all subprojects";
      command = ''
        for dir in nix-config nix-lib nix-keys nix-secrets; do
          if [ -d "$dir" ]; then
            echo "=== $dir ==="
            git -C "$dir" status -sb
            echo
          fi
        done
      '';
    }
    {
      name = "pull";
      category = "workspace";
      help = "Pull all subprojects";
      command = ''
        for dir in nix-config nix-lib nix-keys nix-secrets; do
          if [ -d "$dir" ]; then
            echo "=== Pulling $dir ==="
            git -C "$dir" pull --rebase
          fi
        done
      '';
    }
    {
      name = "update-all";
      category = "flake";
      help = "Update flake.lock for workspace";
      command = "nix flake update";
    }
  ];
}
