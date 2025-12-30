# devshells/nix-repos.nix
# Base shell for nix-repos workspace (local flake adds scripts)
{
  pkgs,
  mkProjectShell,
  ...
}:
mkProjectShell {
  name = "nix-repos";

  motd = ""; # Local flake provides MOTD

  packages = with pkgs; [
    nh
    nix-diff
    gnumake
  ];

  commands = [ ];
}
