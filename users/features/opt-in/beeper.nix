# users/features/opt-in/beeper.nix
#
# Beeper universal chat app
# For non-NixOS: also enable nixgl feature for GPU acceleration
#
{
  pkgs,
  lib,
  config,
  ...
}:
{
  # Tell nixgl to wrap beeper if nixgl is enabled
  nixgl.wrapBeeper = lib.mkIf (config.nixgl.enable or false) true;

  # Only install beeper directly if nixgl is not providing it
  home.packages = lib.optionals (!(config.nixgl.enable or false)) [ pkgs.beeper ];
}
