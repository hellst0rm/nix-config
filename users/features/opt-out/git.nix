# users/features/opt-out/git.nix
#
# Git configuration with delta pager and sops-diff
#
{ pkgs, config, ... }:
{
  programs = {
    git = {
      enable = true;

      # New style settings (Home Manager 25.05+)
      settings = {
        user = {
          name = "RogerNavelsaker";
          email = "roger.navelsaker@gmail.com";
        };

        init.defaultBranch = "main";

        pull.rebase = true;

        rebase = {
          autoStash = true;
          autoSquash = true;
        };

        merge.conflictStyle = "diff3";

        diff = {
          colorMoved = "default";
          sopsdiffer.textconv = "sops -d --config /dev/null";
        };

        # Credential helpers for GitHub
        "credential \"https://github.com\"" = {
          helper = [
            ""
            "!${pkgs.gh}/bin/gh auth git-credential"
          ];
        };
        "credential \"https://gist.github.com\"" = {
          helper = [
            ""
            "!${pkgs.gh}/bin/gh auth git-credential"
          ];
        };

        # Core settings
        core = {
          editor = "hx";
          autocrlf = "input";
        };

        # Push settings
        push = {
          default = "current";
          autoSetupRemote = true;
        };

        # Fetch settings
        fetch.prune = true;

        # Safe directory (allow all under Repositories)
        safe.directory = "${config.home.homeDirectory}/Repositories/*";

        # Aliases (new location)
        alias = {
          st = "status";
          co = "checkout";
          br = "branch";
          ci = "commit";
          unstage = "reset HEAD --";
          last = "log -1 HEAD";
          visual = "!gitk";
          lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
          # Amend without editing message
          amend = "commit --amend --no-edit";
          # Show files changed in last commit
          changed = "diff-tree --no-commit-id --name-only -r HEAD";
        };
      };

      ignores = [
        # macOS
        ".DS_Store"
        # Editors
        "*.swp"
        "*.swo"
        "*~"
        ".idea/"
        ".vscode/"
        # Nix
        "result"
        "result-*"
        # direnv
        ".direnv/"
        ".envrc.local"
        # Node
        "node_modules/"
        # Python
        "__pycache__/"
        "*.pyc"
        ".venv/"
        "venv/"
      ];
    };

    # Delta pager (separate program now)
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        side-by-side = false;
        line-numbers = true;
        syntax-theme = "base16";
      };
    };

    # GitHub CLI
    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
  };

  # Force overwrite existing gh config (common on existing systems)
  xdg.configFile."gh/config.yml".force = true;

  home.packages = with pkgs; [
    git-crypt
    sops
  ];
}
