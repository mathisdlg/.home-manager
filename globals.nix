# globals.nix
#
# Single source of truth for values that need to stay consistent across the
# whole flake — both the NixOS system config and the home-manager config —
# instead of being hardcoded (and drifting) across many module files.
#
# How it reaches modules: flake.nix imports this file and passes it through
# as `globals` via `specialArgs` (NixOS) / `extraSpecialArgs` (home-manager).
# Both mechanisms hand `globals` to every module in their tree, nested ones
# included, with no manual threading — so any module that wants a value just
# adds `globals` to its function arguments and reads e.g. `globals.username`.
# A module that doesn't need it can ignore it entirely via its `...`.
#
# Personalizing a fresh clone / fresh install is now a single-file edit:
# `install.sh` (and manual setups, per the README) only need to change the
# values below — `hostName` and `username` in particular, since flake.nix
# reads them to name the nixosConfigurations/homeConfigurations entries.
#
# Only one machine is defined today. To support a second machine down the
# line without long-lived diverging branches, this file could be split into
# e.g. `hosts/<name>/globals.nix` with flake.nix looping over them — not done
# here since that's a separate piece of work.
rec {
  # Used to key nixosConfigurations in flake.nix and as networking.hostName.
  hostName = "NixosMathisLaptop";

  # Used to key homeConfigurations in flake.nix, as the system user account,
  # and as home.username in home-manager.
  username = "mathis";

  # Derived paths — change automatically when `username` changes above.
  homeDirectory = "/home/${username}";
  repoPath = "${homeDirectory}/.home-manager";
  wallpaperDir = "${homeDirectory}/.wallpapers";

  # Not derived (lives on a separate disk/mount) — personalize by hand.
  musicDir = "/disks/data/Music/Musique";

  # Display name (e.g. for the user account's GECOS field) and git identity.
  # Not derivable from the above, so personalize these by hand.
  fullName = username;
  gitEmail = "delage.mathis.1@gmail.com";

  # System locale/timezone, also centralized since they're "global" in the
  # same sense — one value, read wherever needed.
  timeZone = "Europe/Paris";
  locale = "fr_FR.UTF-8";
}
