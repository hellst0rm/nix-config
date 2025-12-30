# devshells/senshac.nix
# Senshac website development shell
{
  pkgs,
  mkProjectShell,
  ...
}:
mkProjectShell {
  name = "senshac";

  motd = ''
    ╔════════════════════════════════════════════╗
    ║  Senshac Website Development              ║
    ╚════════════════════════════════════════════╝

    Astro + Cloudflare Pages website.

    Commands:
      dev                   Start dev server
      build                 Build for production
      preview               Preview production build
      menu                  Show all commands
  '';

  packages = with pkgs; [
    nodejs_22
    nodePackages.pnpm
    wrangler
  ];

  commands = [
    {
      name = "dev";
      category = "development";
      help = "Start Astro dev server";
      command = "pnpm dev";
    }
    {
      name = "build";
      category = "development";
      help = "Build for production";
      command = "pnpm build";
    }
    {
      name = "preview";
      category = "development";
      help = "Preview production build";
      command = "pnpm preview";
    }
    {
      name = "deploy";
      category = "deployment";
      help = "Deploy to Cloudflare Pages";
      command = "pnpm run deploy";
    }
    {
      name = "install";
      category = "setup";
      help = "Install dependencies";
      command = "pnpm install";
    }
  ];

  env = [
    {
      name = "NODE_ENV";
      value = "development";
    }
  ];
}
