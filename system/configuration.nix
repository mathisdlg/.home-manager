# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }: {
	imports = [ # Include the results of the hardware scan.
		./hardware-configuration.nix
		../patches/nvidia.nix
	];

	# Bootloader.
	boot = {
		loader = {
			efi.canTouchEfiVariables = true;
			systemd-boot = {
				enable = true;
				editor = false;
			};
			timeout = 1;
		};
		supportedFilesystems = [ "ntfs" "btrfs" ];
		tmp.useTmpfs = true;
		plymouth.enable = true;
		initrd.kernelModules = [ "amdgpu" ];
	};

	# Activate Zram swap
	zramSwap = {
		enable = true;
		memoryPercent = 100;
		algorithm = "zstd";
	};

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
			videoDrivers = [ "amdgpu" ];

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
	};

	# Configure console keymap
	console.keyMap = "fr-pc";

	hardware.pulseaudio.enable = false;
	security.rtkit.enable = true;

	# Enable touchpad support (enabled default in most desktopManager).
	# services.xserver.libinput.enable = true;

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.mathisdlg = {
		isNormalUser = true;
		description = "mathisdlg";
		extraGroups = [ "networkmanager" "wheel" ];
		packages = with pkgs; [];
	};

	# Allow unfree packages
	nixpkgs.config.allowUnfree = true;

	environment = {
		systemPackages = with pkgs; [
			# Essentials
			neovim
			brightnessctl
			pavucontrol
			libreoffice
			git
			tree
			gparted
			alsa-utils
			pciutils

			#NixOs
			home-manager

			# Hyprland
			kitty
			wofi

			# Communication
			thunderbird

			# Music
			rhythmbox

			# Config
			qt6ct
		];

		# Environment Variables
		sessionVariables = {
			"XDG_SESSION_TYPE" = "wayland";
			"NIXOS_OZONE_WL" = "1";
			"QT_QPA_PLATFORM" = "wayland";
			"GDK_BACKEND" = "wayland";
		};

		gnome.excludePackages = (with pkgs; [
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
			seahorse # password manager
			gedit # text editor
			cheese # webcam tool
			epiphany # web browser
			geary # email reader
			evince # document viewer
			totem # video player
		]);
	};

	programs = {
		# Steam
		steam = {
			enable = true;
		};

		# Hyprland
		hyprland = {
			enable = true;
			xwayland.enable = true;
		};
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
	virtualisation.docker.rootless = {
		enable = true;
		setSocketVariable = true;
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
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
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
