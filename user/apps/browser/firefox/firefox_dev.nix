{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.browser.firefox_dev;
  firefoxCfg = config.services.apps.browser.firefox;

  # KeePassXC-Browser n'a de sens que si l'application est installée par le
  # module services.apps.security.keepassxc
  keepassxcId = "keepassxc-browser@keepassxc.org";
  keepassxcEnabled = config.services.apps.security.keepassxc.enable;

  extensions =
    cfg.extensions
    // optionalAttrs keepassxcEnabled {
      ${keepassxcId} = "keepassxc-browser";
    };

  nixIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

  # Fabrique un moteur de recherche personnalisé à partir d'un alias, d'une URL
  # et de paramètres GET ({searchTerms} est remplacé par Firefox).
  mkEngine = alias: template: params: {
    urls = [
      {
        inherit template;
        params = mapAttrsToList (name: value: { inherit name value; }) params;
      }
    ];
    icon = nixIcon;
    definedAliases = [ alias ];
  };

  customEngines = {
    "Nix Packages" = mkEngine "@np" "https://search.nixos.org/packages" {
      channel = "unstable";
      query = "{searchTerms}";
    };
    "NixOS Options" = mkEngine "@no" "https://search.nixos.org/options" {
      channel = "unstable";
      query = "{searchTerms}";
    };
    "Home Manager Options" = mkEngine "@hm" "https://home-manager-options.extranix.com/" {
      query = "{searchTerms}";
      release = "master";
    };
    "NixOS Wiki" = mkEngine "@nw" "https://wiki.nixos.org/w/index.php" {
      search = "{searchTerms}";
    };
    "My NixOS" = mkEngine "@n" "https://mynixos.com/search" {
      q = "{searchTerms}";
    };
  };

  # Politiques d'entreprise : verrouillées, non modifiables depuis l'interface.
  basePolicies = {
    DisableTelemetry = true;
    DisableFirefoxStudies = true;
    DisablePocket = true;
    DontCheckDefaultBrowser = true;

    EnableTrackingProtection = {
      Value = true;
      Locked = true;
      Cryptomining = true;
      Fingerprinting = true;
      EmailTracking = true;
    };

    # Pas de suggestions sponsorisées ni de messages promotionnels
    FirefoxSuggest = {
      WebSuggestions = false;
      SponsoredSuggestions = false;
      ImproveSuggest = false;
      Locked = true;
    };
    UserMessaging = {
      ExtensionRecommendations = false;
      FeatureRecommendations = false;
      MoreFromMozilla = false;
      SkipOnboarding = true;
      UrlbarInterventions = false;
      WhatsNew = false;
    };
  };

  # Extensions installées via la politique ExtensionSettings (pas besoin de NUR).
  # La clé est l'ID de l'extension, la valeur son « slug » sur addons.mozilla.org.
  amoExtensions = mapAttrs (_: slug: {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
    installation_mode = "normal_installed"; # l'utilisateur peut la désactiver
  }) extensions;

  # Tes propres extensions : fichiers .xpi locaux, copiés dans le store.
  localExtensions = mapAttrs (_: xpi: {
    install_url = "file://${xpi}";
    installation_mode = "normal_installed";
  }) cfg.localExtensions;

  extensionPolicies = optionalAttrs (amoExtensions != { } || localExtensions != { }) {
    ExtensionSettings = amoExtensions // localExtensions;
  };

  # Autorités de certification internes (ex. celle de tes services *.home.lan).
  # L'interpolation "${c}" copie le fichier dans le store : le chemin reste
  # valide quelle que soit la machine.
  certificatePolicies = optionalAttrs (cfg.trustedCertificates != [ ]) {
    Certificates.Install = map (c: "${c}") cfg.trustedCertificates;
  };

  policies = recursiveUpdate (
    basePolicies // extensionPolicies // certificatePolicies
  ) cfg.extraPolicies;

  # Réglages (about:config) modifiables par l'utilisateur
  baseSettings = {
    "browser.startup.homepage" = "about:home";
    "browser.disableResetPrompt" = true;
    "browser.download.panel.shown" = true;
    "browser.download.useDownloadDir" = false; # demande où enregistrer
    "browser.feeds.showFirstRunUI" = false;
    "browser.messaging-system.whatsNewPanel.enabled" = false;
    "browser.bookmarks.addedImportButton" = false;

    # Désactive l'invite « enregistrer le mot de passe »
    "signon.rememberSignons" = false;
  };

  newTabSettings = {
    "browser.newtabpage.activity-stream.feeds.topsites" = false;
    "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
    "browser.urlbar.suggest.quicksuggest.sponsored" = false;
    "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
  };

  privacySettings = {
    "dom.security.https_only_mode" = true;
    "privacy.globalprivacycontrol.enabled" = true;
  };

  # La politique DisableTelemetry couvre déjà toolkit.telemetry.* et
  # datareporting.* : on ne garde ici que ce qu'elle ne couvre pas.
  telemetrySettings = {
    "browser.discovery.enabled" = false;
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.ping-centre.telemetry" = false;
  };

  # Seules Developer Edition, Nightly et ESR honorent ce réglage ; la version
  # release l'ignore. Les extensions installées depuis about:addons
  # (« Installer un module depuis un fichier ») restent après redémarrage,
  # contrairement à celles chargées depuis about:debugging.
  devSettings = optionalAttrs cfg.allowUnsignedExtensions {
    "xpinstall.signatures.required" = false;
  };

  languageSettings = optionalAttrs (cfg.languagePacks != [ ]) {
    "intl.accept_languages" = concatStringsSep "," cfg.languagePacks;
  };

  settings =
    baseSettings
    // newTabSettings
    // privacySettings
    // telemetrySettings
    // devSettings
    // languageSettings
    // cfg.extraSettings;
in
{
  options.services.apps.browser.firefox_dev = {
    enable = mkEnableOption "Enable firefox developer edition browser.";

    languagePacks = mkOption {
      type = types.listOf types.str;
      default = [
        "fr"
        "en-US"
      ];
      description = "Paquets de langue installés ; sert aussi à construire intl.accept_languages.";
    };

    extensions = mkOption {
      type = types.attrsOf types.str;
      default = {
        "uBlock0@raymondhill.net" = "ublock-origin";
      };
      example = literalExpression ''
        {
          "uBlock0@raymondhill.net" = "ublock-origin";
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
        }
      '';
      description = ''
        Extensions à installer : ID de l'extension -> slug addons.mozilla.org.
        KeePassXC-Browser n'est pas à lister ici : il est ajouté automatiquement
        quand services.apps.security.keepassxc.enable est activé.
      '';
    };

    allowUnsignedExtensions = mkOption {
      type = types.bool;
      default = true;
      description = "Autorise l'installation d'extensions non signées (xpinstall.signatures.required = false).";
    };

    localExtensions = mkOption {
      type = types.attrsOf types.path;
      default = { };
      example = literalExpression ''
        { "mon-extension@mathisdlg" = ./extensions/mon-extension.xpi; }
      '';
      description = ''
        Extensions personnelles à installer de façon déclarative : ID de l'extension
        (browser_specific_settings.gecko.id du manifest) -> fichier .xpi.
        Nécessite allowUnsignedExtensions si elles ne sont pas signées.
      '';
    };

    trustedCertificates = mkOption {
      type = types.listOf types.path;
      default = [ ];
      example = literalExpression "[ ./certs/home-lan-ca.crt ]";
      description = ''
        Certificats d'autorités de certification (format PEM/DER) à faire approuver
        par Firefox, typiquement la CA qui signe les sites en .home.lan.
        Ce doit être le certificat racine (la CA), pas celui d'un site.
      '';
    };

    extraSettings = mkOption {
      type = with types; attrsOf (oneOf [ bool int str ]);
      default = { };
      description = "Clés about:config supplémentaires ou surchargées, propres à une machine.";
    };

    extraPolicies = mkOption {
      type = types.attrs;
      default = { };
      description = "Politiques Firefox supplémentaires, fusionnées récursivement avec celles du module.";
    };
  };

  config = mkIf cfg.enable {
    # Home Manager ne gère qu'une seule instance de programs.firefox.
    assertions = [
      {
        assertion = !firefoxCfg.enable;
        message = "services.apps.browser.firefox et firefox_dev utilisent tous deux programs.firefox : n'en active qu'un seul.";
      }
    ];

    warnings = optional (!keepassxcEnabled) ''
      firefox_dev : l'extension KeePassXC-Browser n'est pas installée car
      services.apps.security.keepassxc.enable est désactivé.
    '';

    programs.firefox = {
      enable = true;
      package = pkgs.firefox-devedition;
      configPath = "${config.xdg.configHome}/mozilla/firefox";
      languagePacks = cfg.languagePacks;
      inherit policies;

      # Pont entre l'extension KeePassXC-Browser et l'application KeePassXC
      nativeMessagingHosts = optional keepassxcEnabled pkgs.keepassxc;

      profiles.dev-edition-default = {
        id = 0;
        name = "dev-edition-default";
        isDefault = true;

        search = {
          # Nécessaire : Firefox réécrit search.json.mozlz4 et ferait échouer
          # l'activation Home Manager sans cette option.
          force = true;
          default = "ddg";
          privateDefault = "ddg";
          order = [
            "ddg"
            "google"
          ] ++ attrNames customEngines;
          engines = customEngines // {
            "bing".metaData.hidden = true;
          };
        };

        inherit settings;
      };
    };
  };
}
