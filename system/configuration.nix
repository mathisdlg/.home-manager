# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, globals, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./boot.nix

    ../patches/nvidia.nix

    ./import.nix
  ];

  networking = {
    hostName = globals.hostName;
    wireless.iwd.enable = true;
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = globals.timeZone;

  # Select internationalisation properties.
  i18n = {
    defaultLocale = globals.locale;
    extraLocaleSettings = {
      LC_ADDRESS = globals.locale;
      LC_IDENTIFICATION = globals.locale;
      LC_MEASUREMENT = globals.locale;
      LC_MONETARY = globals.locale;
      LC_NAME = globals.locale;
      LC_NUMERIC = globals.locale;
      LC_PAPER = globals.locale;
      LC_TELEPHONE = globals.locale;
      LC_TIME = globals.locale;
    };
  };

  services = {
    xserver = {
      enable = true;

      # Configure keymap in X11
      xkb = {
        layout = "fr";
        variant = "azerty";
      };
    };

    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable nvidia driver patch
    nvidia.enable = false; # I have an AMD GPU now! :happy:

    fstrim.enable = true;

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true; # explicit, though this is nixpkgs' own default when pipewire is on
    };

    pulseaudio.enable = false;

    # Allow the kernel to manage power on/off of drives for suspend, shutdown, hibernate
    udev.extraRules = ''
      ACTION=="add|change", DRIVERS=="usb-storage|uas", SUBSYSTEM=="scsi_disk", ATTR{manage_system_start_stop}="1", ATTR{manage_runtime_start_stop}="1", ATTR{manage_shutdown}="1"
    '';

    udisks2.enable = true;
    gvfs.enable = true; # Optional but recommended for file manager compatibility

    upower.enable = true;
    power-profiles-daemon.enable = true;

    blueman.enable = true;
  };

  # Configure console keymap
  console.keyMap = "fr-pc";

  security.rtkit.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${globals.username} = {
    isNormalUser = true;
    description = globals.fullName;
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
    ];
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
      "steam-run"
      "steamcmd"
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      # Essentials
      brightnessctl
      pavucontrol
      git
      tree
      gparted
      alsa-utils
      pciutils

      #NixOs
      home-manager

      # Config
      qt6Packages.qt6ct
    ];

    # Environment Variables
    sessionVariables = {
      "XDG_SESSION_TYPE" = "wayland";
      "NIXOS_OZONE_WL" = "1";
      "QT_QPA_PLATFORM" = "wayland";
      "GDK_BACKEND" = "wayland";
    };
  };

  programs = {
    # Hyprland
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Steam
    steam = {
      enable = false;
    };
  };

  # GTK4/libadwaita apps (Nautilus) don't read dconf's color-scheme key
  # directly on a non-GNOME session like Hyprland — they ask the XDG
  # Desktop Portal's Settings interface instead. Without a portal backend
  # that actually implements that interface, day/night's dconf write (see
  # ../user/desktop/themes/day_night/day_night.nix) has nowhere to go: it updates
  # dconf correctly, but nothing relays it to already-running or
  # newly-launched apps, so they silently keep whatever they started with.
  # xdg-desktop-portal-gtk is that backend (it watches GSettings/dconf
  # itself and serves it over the portal) — hyprland's own portal handles
  # screenshare/screenshot, not Settings, so both are needed together.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      hyprland.default = [ "hyprland" "gtk" ];
      common.default = [ "gtk" ];
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #	enable = true;
  #	enableSSHSupport = true;
  # };

  # List services that you want to enable:
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 10d";
    };

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
  };

  systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 6060 ];
  # networking.firewall.allowedUDPPorts = [ 9876 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
