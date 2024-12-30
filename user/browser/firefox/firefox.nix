{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.firefox; in {
	options.services.firefox.enable = mkEnableOption "Enable firefox browser.";

	config = mkIf cfg.enable {
		programs.firefox = {
			enable = true;
			package = pkgs.firefox; # -devedition-bin
			# languagePacks = [ "fr" "en-US" ];
			policies = {
				DisableTelemetry = true;
				DisableFirefoxStudies = true;
				DisablePocket = true;

				EnableTrackingProtection = {
					Value = true;
					Locked = true;
					Cryptomining = true;
					Fingerprinting = true;
				};

				DontCheckDefaultBrowser = true;
			};
			profiles = {
				default = {
					id = 0;
					isDefault = true; # No effect?
					name = "Default";

					search = {
						privateDefault = "DuckDuckGo";
						order = ["DuckDuckGo" "Google"];
						engines = {
							"My nixos" = {
								urls = [{
									template = "https://mynixos.com/search";
									params = [
										{ name = "q"; value = "{searchTerms}"; }
									];
								iconUpdateURL = "https://mynixos.com/favicon.ico";
								}];

								icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
								definedAliases = [ "@n" ];
							};
						};
					};

					bookmarks = {};

					settings = { # with the help of https://github.com/Misterio77/nix-config/blob/main/home/gabriel/features/desktop/common/firefox.nix
						"browser.startup.homepage" = "about:home";
						"browser.disableResetPrompt" = true;
						"browser.download.panel.shown" = true;
						"browser.feeds.showFirstRunUI" = false;
						"browser.messaging-system.whatsNewPanel.enabled" = false;
						"browser.bookmarks.addedImportButton" = false;
						"browser.download.useDownloadDir" = false;
						"browser.newtabpage.activity-stream.feeds.topsites" = false;
						"browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
						"browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;

						# Disable some telemetry
						"app.shield.optoutstudies.enabled" = false;
						"browser.discovery.enabled" = false;
						"browser.newtabpage.activity-stream.feeds.telemetry" = false;
						"browser.newtabpage.activity-stream.telemetry" = false;
						"browser.ping-centre.telemetry" = false;
						"datareporting.healthreport.service.enabled" = false;
						"datareporting.healthreport.uploadEnabled" = false;
						"datareporting.policy.dataSubmissionEnabled" = false;
						"datareporting.sessions.current.clean" = true;
						"devtools.onboarding.telemetry.logged" = false;
						"toolkit.telemetry.archive.enabled" = false;
						"toolkit.telemetry.bhrPing.enabled" = false;
						"toolkit.telemetry.enabled" = false;
						"toolkit.telemetry.firstShutdownPing.enabled" = false;
						"toolkit.telemetry.hybridContent.enabled" = false;
						"toolkit.telemetry.newProfilePing.enabled" = false;
						"toolkit.telemetry.prompted" = 2;
						"toolkit.telemetry.rejected" = true;
						"toolkit.telemetry.reportingpolicy.firstRun" = false;
						"toolkit.telemetry.server" = "";
						"toolkit.telemetry.shutdownPingSender.enabled" = false;
						"toolkit.telemetry.unified" = false;
						"toolkit.telemetry.unifiedIsOptIn" = false;
						"toolkit.telemetry.updatePing.enabled" = false;


						# Disable "save password" prompt
						"signon.rememberSignons" = false;
					};
				};
			};
		};
	};
}