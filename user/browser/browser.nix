# Ties hyprland's $browser keybind, dunst's notification-click browser, etc.
# to whichever browser is actually enabled below, instead of each of those
# modules separately hardcoding a browser name (which drifted out of sync
# more than once in this repo's history).
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.browser;

  # Plain launch command for each browser — used for "just open the browser"
  # (e.g. a bare keybind).
  launchCommands = {
    brave = "brave";
    firefox = "firefox";
    firefox-dev = "firefox-devedition";
  };

  # Command used by things that need to open a link in the default browser
  # (e.g. dunst's notification click-through). Firefox-family browsers need
  # `-new-tab` to reuse the existing window instead of spawning a new one;
  # Brave (Chromium-based) already does that when just given a URL.
  notifyCommands = {
    brave = "/usr/bin/env brave";
    firefox = "/usr/bin/env firefox -new-tab";
    firefox-dev = "/usr/bin/env firefox-devedition -new-tab";
  };
in
{
  options.services.browser.default = mkOption {
    type = types.enum [
      "brave"
      "firefox"
      "firefox-dev"
    ];
    default = "brave"; # matches whichever of the browsers below is enabled today
    description = ''
      Which browser other modules (hyprland's $browser keybind, dunst's
      notification-click browser, ...) should treat as "the" browser.
      Forces services.browser.<name>.enable on for whichever browser is
      named here, regardless of what that option is set to below — so
      switching browsers is a one-line change.
    '';
  };

  options.services.browser.command = mkOption {
    type = types.str;
    readOnly = true;
    default = launchCommands.${cfg.default};
    description = "Shell command that launches the default browser.";
  };

  options.services.browser.notifyCommand = mkOption {
    type = types.str;
    readOnly = true;
    default = notifyCommands.${cfg.default};
    description = "Shell command used to open a link (from e.g. a notification) in the default browser.";
  };

  config = {
    # Whichever browser is named as `default` gets enabled no matter what its
    # own .enable is set to below — mkForce wins over a plain `= true;`/
    # `= false;` written anywhere else, so `default` alone is enough to
    # switch browsers.
    #
    # This has to be three static mkIf branches rather than
    # `services.browser.${cfg.default}.enable = mkForce true;` — that looked
    # simpler, but reading cfg.default (part of services.browser) to build an
    # attribute name that's *also* merged back into services.browser is a
    # genuine circular dependency: Nix needs cfg.default's value to know
    # which attribute this module defines, and needs to know the full set of
    # definitions to resolve cfg.default. Infinite recursion. Each branch
    # below has a fixed, static attribute name, so there's nothing circular
    # left — only whether the branch is active depends on cfg.default.
    services.browser.brave.enable = mkIf (cfg.default == "brave") (mkForce true);
    services.browser.firefox.enable = mkIf (cfg.default == "firefox") (mkForce true);
    services.browser.firefox-dev.enable = mkIf (cfg.default == "firefox-dev") (mkForce true);
  };
}
