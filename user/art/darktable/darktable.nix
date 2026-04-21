{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.art.darktable;
in
{
  options.services.art.darktable.enable = mkEnableOption "Enable darktable.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      darktable
    ];

    home.file.".config/darktable/darktablerc".text = ''
      ui_last/theme=darktable-icons-highcontrast

      context_help/url=https://docs.darktable.org/usermanual/
      context_help/use_default_url=true

      plugins/darkroom/modulegroups_preset=Modules : Tous

      plugins/darkroom/clipping/extra_aspect_ratios/insta_square=100:100
      plugins/darkroom/clipping/extra_aspect_ratios/insta_portrait=400:500
      plugins/darkroom/clipping/extra_aspect_ratios/insta_landscape=100:191

      plugins/imageio/storage/disk/file_directory=$(FILE_FOLDER)/Final/$(FILE_NAME)
    '';
  };
}
