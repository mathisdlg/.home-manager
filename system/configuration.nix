# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../patches/nvidia.nix
    ./modules/zram/zram.nix
    ./modules/openrgb/openrgb.nix
    ./modules/bootloader/bootloader.nix
  ];

  networking = {
    hostName = "nixosMathis"; # Define your hostname.
    networkmanager.enable = true;
    wireless.iwd.enable = true;
    networkmanager.wifi.backend = "iwd";
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "fr_FR.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };
  };

  services = {
    xserver = {
      enable = true;

      # Enable the GNOME Desktop Environment.
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

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

    # Activate zram
    zram = {
      enable = true;
      size = 100;
    };

    rgb.openrgb = {
      enable = false;
    };

    fstrim.enable = true;

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };

    mysql = {
      enable = true;
      package = pkgs.mariadb;
    };

    spice-vdagentd.enable = true;

    bootloader-mod.enable = true;

    pulseaudio.enable = false;
  };

  # Configure console keymap
  console.keyMap = "fr-pc";

  security.rtkit.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mathisdlg = {
    isNormalUser = true;
    description = "mathisdlg";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "kvm"
      "dialout"
    ];
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    # permittedInsecurePackages = [
    # 	"dotnet-runtime-wrapped-6.0.36"
    # 	"dotnet-runtime-6.0.36"
    # 	"dotnet-sdk-wrapped-6.0.428"
    # 	"dotnet-sdk-6.0.428"
    # ];
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
      qt6ct

      # Virtualisation
      spice
      spice-protocol
    ];

    # Environment Variables
    sessionVariables = {
      "XDG_SESSION_TYPE" = "wayland";
      "NIXOS_OZONE_WL" = "1";
      "QT_QPA_PLATFORM" = "wayland";
      "GDK_BACKEND" = "wayland";
    };

    gnome.excludePackages = (
      with pkgs;
      [
        gnome-photos
        gnome-tour
        gnome-music
        gnome-font-viewer
        gnome-connections
        gnome-terminal
        gnome-console
        gnome-weather
        gnome-calendar
        gnome-characters
        gnome-clocks
        gnome-contacts
        gnome-color-manager
        gnome-logs
        gnome-maps
        gnome-system-monitor
        seahorse # password manager
        gedit # text editor
        cheese # webcam tool
        snapshot # Camera tool
        epiphany # web browser
        geary # email reader
        evince # document viewer
        totem # video player
        # loupe # image viewer
        baobab # disk usage analyzer
      ]
    );
  };

  programs = {
    # Hyprland
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Steam
    steam = {
      enable = true;
    };

    # Virtualisation
    virt-manager.enable = true;
  };

  # Hardware graphics librairies
  # hardware.graphics.enable = true; # problems with flake downgrade to stable version

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #	enable = true;
  #	enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Docker rootless
  virtualisation = {
    docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };

    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMF.fd ]; # pkgs.OVMFFull.fd
        };
      };
    };

    spiceUSBRedirection.enable = true;
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 10d";
    };

    optimise = {
      automatic = true;
    };

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

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
