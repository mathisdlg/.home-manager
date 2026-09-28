{
  config,
  pkgs,
  lib,
  ...
}: {
  config = {
    wayland.windowManager.hyprland = {
      settings = {
        general = {
          gaps_in=2;
          gaps_out=2;
          border_size=2;
          "col.active_border"="rgba(33ccffee) rgba(aae5a4ff) 45deg";
          "col.inactive_border"="rgba(595959aa)";

          layout="dwindle";
          
          allow_tearing=false;
        };
      };
    };
  };
}