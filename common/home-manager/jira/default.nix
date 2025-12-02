{
  config,
  pkgs,
  ...
}: {
  home = {
    packages = [pkgs.go-jira];
    file.".jira.d".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/jira";
  };

  xdg.configFile = {
    "jira/templates" = {
      source = ./templates;
      recursive = true;
    };

    "jira/config.yml".source = let
      yaml = pkgs.formats.yaml {};
    in
      yaml.generate "go-jira-config" (import ./config.nix);
  };
}
