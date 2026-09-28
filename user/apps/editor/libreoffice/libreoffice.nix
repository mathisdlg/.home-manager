{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.editor.libreoffice;
in
{
  options.services.apps.editor.libreoffice.enable = mkEnableOption "Enable libreoffice.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      libreoffice
      hunspell
      hunspellDicts.fr-moderne
      hunspellDicts.fr-any
      hunspellDicts.en_US
    ];
  };
}
