# devshells/codebase-mcp.nix
# Codebase MCP server development shell
{
  pkgs,
  mkProjectShell,
  ...
}:
mkProjectShell {
  name = "codebase-mcp";

  motd = ''
    ╔════════════════════════════════════════════╗
    ║  Codebase MCP Server Development          ║
    ╚════════════════════════════════════════════╝

    MCP server for codebase analysis and navigation.

    Commands:
      build                 Build the project
      run                   Run the MCP server
      test                  Run tests
      menu                  Show all commands
  '';

  packages = with pkgs; [
    # Rust toolchain
    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt

    # Build dependencies
    pkg-config
    openssl

    # Code analysis tools
    tree-sitter
    ctags
  ];

  commands = [
    {
      name = "build";
      category = "development";
      help = "Build the project";
      command = "cargo build";
    }
    {
      name = "release";
      category = "development";
      help = "Build release version";
      command = "cargo build --release";
    }
    {
      name = "run";
      category = "development";
      help = "Run the MCP server";
      command = "cargo run";
    }
    {
      name = "test";
      category = "validation";
      help = "Run tests";
      command = "cargo test";
    }
    {
      name = "clippy";
      category = "validation";
      help = "Run clippy lints";
      command = "cargo clippy -- -W clippy::pedantic";
    }
    {
      name = "fmt-rust";
      category = "validation";
      help = "Format Rust code";
      command = "cargo fmt";
    }
  ];

  env = [
    {
      name = "RUST_BACKTRACE";
      value = "1";
    }
  ];
}
