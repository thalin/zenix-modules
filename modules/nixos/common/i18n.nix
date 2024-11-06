{
  config,
  namespace,
  lib,
  ...
}:
let
  cfg = config.${namespace}.i18n;
  inherit (lib) mkOption types;
in
{
  # options.${namespace}.i18n = {
  #   locale = mkOption {
  #     type = types.str;
  #     default = "en_US.UTF-8";
  #   };
  # };

  # config = {
  #   i18n.defaultLocale = cfg.locale;
  #
  #   i18n.extraLocaleSettings = {
  #     LC_ADDRESS = cfg.locale;
  #     LC_IDENTIFICATION = cfg.locale;
  #     LC_MEASUREMENT = cfg.locale;
  #     LC_MONITARY = cfg.locale;
  #     LC_NAME = cfg.locale;
  #     LC_NUMERIC = cfg.locale;
  #     LC_PAPER = cfg.locale;
  #     LC_TELEPHONE = cfg.locale;
  #     LC_TIME = cfg.locale;
  #   };
  # };

  config = {
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONITARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };
}
