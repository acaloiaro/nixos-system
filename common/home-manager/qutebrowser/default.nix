{config, ...}: {
  programs.qutebrowser = {
    enable = true;
    searchEngines = {
      DEFAULT = "https://kagi.com/search?q={}";
      glean = "https://app.glean.com/search?q={}";
      hm = "https://home-manager-options.extranix.com/?query={}";
      nixpkgs = "https://search.nixos.org/packages?query={}";
      nixos = "https://search.nixos.org/options?query={}";
      nixman = "https://nixos.org/manual/nix/unstable/?search={}";
    };
    keyBindings = let
      pass_cmd = "spawn --userscript qute-pass --dmenu-invocation choose --mode gopass --password-store ${config.home.homeDirectory}/.local/share/gopass/stores/root";
    in {
      normal = {
        ",p" = pass_cmd;
        ",Pu" = "${pass_cmd} --username-only";
        ",Pp" = "${pass_cmd} --password-only";
        ",Po" = "${pass_cmd} --otp-only";
        ",," = "config-cycle tabs.show never always";
        ",qc" = "spawn --userscript ~/.local/bin/qute-logseq";
        "<Ctrl+Shift+j>" = "tab-move +";
        "<Ctrl+Shift+k>" = "tab-move -";
      };
    };
    quickmarks = {
      nixpkgs = "https://github.com/NixOS/nixpkgs";
      home-manager = "https://github.com/nix-community/home-manager";
    };
    settings = {
      url.start_pages = [
        "https://kagi.com"
      ];
      spellcheck.languages = ["en-US"];
      tabs = {
        position = "top";
        show = "always";
        title = {
          format = "{audio}{current_title}";
          format_pinned = "{audio}📌 {current_title}";
        };
      };
      fonts = {
        default_size = "16px";
      };

      # zoom.default = "120%";
      content.javascript.clipboard = "access";
    };
  };
}
