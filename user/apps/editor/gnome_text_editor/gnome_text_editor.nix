{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.editor.gnome_text_editor;
in
{
  options.services.apps.editor.gnome_text_editor.enable =
    mkEnableOption "Enable GNOME Text Editor (open source).";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gnome-text-editor
    ];
  };
}
