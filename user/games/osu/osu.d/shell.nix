{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShellNoCC {
	name = "Osu downloader";

	nativeBuildInputs = with pkgs.buildPackages; [
		wget
		appimage-run
		python3
		icu74
		python311Packages.requests
		python311Packages.beautifulsoup4
	];

	shellHook = ''
		export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
		python osu.py
		appimage-run ~/Games/osu.AppImage
	'';
}