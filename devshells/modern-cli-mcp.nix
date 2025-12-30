# devshells/modern-cli-mcp.nix
# Modern CLI MCP server development shell
{
  pkgs,
  mkProjectShell,
  ...
}:
mkProjectShell {
  name = "modern-cli-mcp";

  motd = ''
    ╔════════════════════════════════════════════╗
    ║  Modern CLI MCP Server Development        ║
    ╚════════════════════════════════════════════╝

    Rust-based MCP server for modern CLI tools.

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

    # Modern CLI tools (for testing)
    fd
    ripgrep
    bat
    eza
    sd
    delta
    procs
    dust
    tokei
    hyperfine
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
