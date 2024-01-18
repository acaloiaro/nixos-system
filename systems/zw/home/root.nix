{ ... }:
{
  # This should be the same value as `system.stateVersion` in
  # your `configuration.nix` file.
  home.stateVersion = "23.05";

  home.file = {
    ".config/helix" = {
      source = ./helix;
      recursive = true;
    };
  };

  programs.helix = {
    enable = true;
    settings = (builtins.fromTOML (builtins.readFile ./helix/config.toml));
    languages = { 
      langauge = (builtins.fromTOML (builtins.readFile ./helix/languages.toml)); 
    };
  };

  programs.git = {
    enable = true;
    userName  = "Adriano Caloiaro";
    userEmail = "code@adriano.fyi";
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      rebuild = "sudo nixos-rebuild switch";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "sudo"
        "git"
        "dotenv"
        "zsh-syntax-highlighting"
        "fzf"
      ];
    };

  };
}

