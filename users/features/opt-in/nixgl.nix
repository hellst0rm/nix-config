# users/features/opt-in/nixgl.nix
#
# nixGL wrapper for GL apps on non-NixOS systems
# Enable this feature for standalone home-manager on Arch/etc.
# NOT needed on NixOS hosts - they handle GL natively
#
# When enabled, this module:
# - Provides wrapped versions of GL apps
# - Other features check nixgl.enable to skip their packages
#
{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  nixgl = inputs.nixgl.packages.${pkgs.system};

  # Wrapper that runs GL apps through nixGLIntel
  wrapGL =
    pkg:
    pkgs.runCommand "${pkg.name}-nixgl" { } ''
      mkdir -p $out/bin
      for bin in ${pkg}/bin/*; do
        name=$(basename $bin)
        cat > $out/bin/$name << EOF
      #!${pkgs.bash}/bin/bash
      exec ${nixgl.nixGLIntel}/bin/nixGLIntel $bin "\$@"
      EOF
        chmod +x $out/bin/$name
      done
      # Link share directory for desktop files, icons, etc
      ln -s ${pkg}/share $out/share 2>/dev/null || true
    '';

  cfg = config.nixgl;
in
{
  options.nixgl = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether nixGL is providing GL-wrapped packages";
    };

    # Apps to wrap (set by other feature modules)
    wrapBeeper = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to wrap beeper with nixGL";
    };
    wrapYubioath = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to wrap yubioath-flutter with nixGL";
    };
  };

  config = {
    # When this feature file is imported, enable nixgl
    nixgl.enable = lib.mkDefault true;

    # Wrap home.packages apps only if requested by other modules
    home.packages =
      lib.optionals (cfg.enable && cfg.wrapBeeper) [ (wrapGL pkgs.beeper) ]
      ++ lib.optionals (cfg.enable && cfg.wrapYubioath) [ (wrapGL pkgs.yubioath-flutter) ];

    # Override programs.* packages with wrapped versions
    programs.alacritty.package = lib.mkIf (cfg.enable && config.programs.alacritty.enable) (
      lib.mkForce (wrapGL pkgs.alacritty)
    );
    programs.kitty.package = lib.mkIf (cfg.enable && config.programs.kitty.enable) (
      lib.mkForce (wrapGL pkgs.kitty)
    );
  };
}
