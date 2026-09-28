# One toggle (`fork`) to switch between VSCodium (open source) and the
# official VS Code (unfree) — everything else (extensions, settings) is
# shared, so switching forks is a one-line change again.
#
# Why this indirection exists: home-manager has two separate modules,
# programs.vscodium and programs.vscode, because they write to different
# config paths on disk (~/.config/VSCodium vs ~/.config/Code) — using
# programs.vscode.package = pkgs.vscodium; used to work but wrote to the
# wrong paths, so home-manager split it into two modules. Without this
# file, switching forks would mean moving your whole profile block from
# one option namespace to the other by hand.
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.editor.vscodium;

  # Shared between both forks — extensions/settings don't change based on
  # which binary is installed.
  profile = {
    extensions = with pkgs.vscode-extensions; [
      # Theme
      # One dark pro
      zhuangtongfa.material-theme
      # Material icon
      pkief.material-icon-theme

      # Code Snap
      adpyke.codesnap

      # Nix
      bbenoist.nix

      # Python pack
      ms-python.python
      ms-python.debugpy

      # Web dev
      formulahendry.auto-close-tag

      # Database
      cweijan.vscode-database-client2

      # Error lens
      usernamehw.errorlens

      # Rainbow CSV
      mechatroner.rainbow-csv

      # Prettier
      esbenp.prettier-vscode

      # C/C++
      ms-vscode.cpptools-extension-pack
    ];

    userSettings = {
      "files.autoSave" = "afterDelay";

      "workbench.colorTheme" = "One Dark Pro";
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.editor.enablePreview" = true;

      "git.confirmSync" = false;
      "git.autofetch" = true;
      "git.enableSmartCommit" = true;

      "editor.fontFamily" = "'JetBrains Mono'";
      "editor.fontWeight" = "normal";
      "editor.fontLigatures" = true;
      "editor.smoothScrolling" = true;
      "editor.rulers" = [
        {
          "column" = 120;
          "color" = "#aae5a4";
        }
      ];
      "editor.tabSize" = 4;
      "editor.renderWhitespace" = "boundary";
      "sonarlint.rules" = {
        "python:S125" = {
          "level" = "off";
        };
      };
      "tabby.endpoint" = "http://localhost:8080";
      "git.openRepositoryInParentFolders" = "always";

      "files.associations" = {
        "config" = "jsonc";
      };

      "database-client.autoSync" = true;

      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;

      "github.copilot.enable" = {
        "*" = true;
        "plaintext" = false;
        "markdown" = true;
      };
      "github.copilot.nextEditSuggestions.enabled" = true;
    };
  };
in
{
  options.services.apps.editor.vscodium.enable = mkEnableOption "Enable visual studio code.";

  options.services.apps.editor.vscodium.fork = mkOption {
    type = types.enum [ "vscodium" "vscode" ];
    default = "vscodium";
    description = ''
      Which build to install and configure — this is the one thing to
      change to switch, everything else below is shared.

      "vscodium": open source (no telemetry, no MS branding).
      "vscode": Microsoft's official build — unfree, but already allowed
      via the allowUnfreePredicate in flake.nix, so just flip this.
    '';
  };

  options.services.apps.editor.vscodium.package = mkOption {
    type = types.package;
    default = if cfg.fork == "vscodium" then pkgs.vscodium else pkgs.vscode;
    defaultText = literalExpression "pkgs.vscodium or pkgs.vscode, matching `fork`";
    description = ''
      The exact package to install. Only override this for something
      unusual (e.g. an insiders build) — normally `fork` above is all you
      need, this follows it automatically.
    '';
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      jetbrains-mono
    ];

    programs.vscodium = mkIf (cfg.fork == "vscodium") {
      enable = true;
      package = cfg.package;
      profiles.default = profile;
    };

    programs.vscode = mkIf (cfg.fork == "vscode") {
      enable = true;
      package = cfg.package;
      profiles.default = profile;
    };
  };
}
