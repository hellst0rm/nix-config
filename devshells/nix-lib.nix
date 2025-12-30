# devshells/nix-lib.nix
# Nix library development shell
{
  pkgs,
  mkProjectShell,
  ...
}:
mkProjectShell {
  name = "nix-lib";

  motd = ''
    ╔════════════════════════════════════════════╗
    ║  Nix Library Development Shell            ║
    ╚════════════════════════════════════════════╝

    Library functions for NixOS/Home Manager configs.

    Commands:
      test                  Run library tests
      check                 Run flake checks
      menu                  Show all commands
  '';

  packages = with pkgs; [
    nixd
  ];

  commands = [
    {
      name = "test";
      category = "validation";
      help = "Run library tests";
      command = "nix flake check";
    }
    {
      name = "check";
      category = "validation";
      help = "Run flake checks";
      command = "nix flake check";
    }
    {
      name = "show";
      category = "validation";
      help = "Display library outputs";
      command = "nix flake show";
    }
  ];
}
