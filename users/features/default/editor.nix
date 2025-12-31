# users/features/default/editor.nix
#
# Helix editor configuration
#
{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      theme = "base16_transparent";

      editor = {
        line-number = "relative";
        cursorline = true;
        auto-save = true;
        auto-format = true;
        idle-timeout = 400;
        completion-trigger-len = 1;
        bufferline = "multiple";
        color-modes = true;

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        file-picker = {
          hidden = false;
          git-ignore = true;
        };

        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        indent-guides = {
          render = true;
          character = "│";
        };

        statusline = {
          left = [
            "mode"
            "spinner"
            "file-name"
            "file-modification-indicator"
          ];
          center = [ ];
          right = [
            "diagnostics"
            "selections"
            "position"
            "file-encoding"
            "file-line-ending"
            "file-type"
          ];
        };
      };

      keys = {
        normal = {
          # Quick save
          "C-s" = ":w";
          # Quick quit
          "C-q" = ":q";
          # Buffer navigation
          "tab" = "goto_next_buffer";
          "S-tab" = "goto_previous_buffer";
          # Close buffer
          "C-w" = ":buffer-close";
        };
        insert = {
          "C-s" = [
            "normal_mode"
            ":w"
          ];
        };
      };
    };

    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "nixfmt-rfc-style";
        }
        {
          name = "fish";
          auto-format = true;
          formatter.command = "fish_indent";
        }
        {
          name = "markdown";
          soft-wrap.enable = true;
        }
      ];
    };
  };

  # Editor packages
  home.packages = with pkgs; [
    # Formatters
    nixfmt-rfc-style
    # LSP servers (basic - language-specific ones come from devshells)
    nil # nix lsp
    marksman # markdown lsp
  ];
}
