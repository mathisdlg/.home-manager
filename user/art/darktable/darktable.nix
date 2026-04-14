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
      plugins/darkroom/clipping/extra_aspect_ratios/insta_square=100:100
      plugins/darkroom/clipping/extra_aspect_ratios/insta_portrait=400:500
      plugins/darkroom/clipping/extra_aspect_ratios/insta_landscape=100:191
    '';
  };
}
