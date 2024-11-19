{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.chawan;
in {
  options.programs.chawan = with lib.types; {
    enable = lib.mkEnableOption "Install and configure chawan";

    cookie = lib.mkOption {
      type = bool;
      description = ''
        Enable/disable cookies on sites

        Note: in Chawan, each website gets a separate cookie jar, so websites
        relying on cross-site cookies may not work as expected. You may use the
        `[[siteconf]]` "cookie-jar" and "third-party-cookie" settings to adjust
        this behavior for specific sites.
      '';
      default = false;
    };

    images = lib.mkOption {
      type = bool;
      description = "Enable/disable experimental image support";
      default = false;
    };

    scripting = lib.mkOption {
      type = bool;
      description = "Enable/disable JavaScript in *all* buffers.";
      default = false;
    };

    cookie-jars-for = lib.mkOption {
      type = listOf str;
      description = "Allow cookie sharing on these domains";
      default = [];
    };

    omnirules = lib.mkOption {
      type = listOf attrs;
      description = "Omnirules https://git.sr.ht/~bptato/chawan/tree/HEAD/doc/config.md#omnirule";
      default = [];
    };

    siteconf = lib.mkOption {
      type = listOf attrs;
      description = "Configuration options can be specified for individual sites. https://git.sr.ht/~bptato/chawan/tree/HEAD/doc/config.md#siteconf";
      default = [];
    };

    pager-keybindings = lib.mkOption {
      type = attrs;
      description = "Pager keybindings https://git.sr.ht/~bptato/chawan/tree/HEAD/doc/config.md#keybindings";
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      chawan
      xsel # chawan uses it to copy/paste
    ];

    xdg.configFile = let
      f = pkgs.formats;
      toml = f.toml {};
    in {
      "chawan/config.toml".source =
        toml.generate "chawan-config"
        {
          buffer = {
            cookie = cfg.cookie;
            scripting = cfg.scripting;
            images = cfg.images;
            referer-from = true;
          };

          input.use-mouse = true;

          display = {
            color-mode = "true-color";
            image-mode = "kitty";
          };

          omnirule = cfg.omnirules;

          siteconf = let
            enable-cookies = domain: {
              host = "(.*\.)?${domain}";
              cookie = true;
              share-cookie-jar = domain;
              third-party-cookie = ".*\.${domain}";
            };
          in
            (map (site: enable-cookies site) cfg.cookie-jars-for)
            ++ cfg.siteconf;

          page = cfg.pager-keybindings;
        };
    };
  };
}
