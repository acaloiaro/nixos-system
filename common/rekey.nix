{
  pkgs,
  inputs,
  ...
}: {
  age.rekey = {
    agePlugins = [
      inputs.age-plugin-gopass.packages.${pkgs.stdenv.hostPlatform.system}.default
      pkgs.age-plugin-tpm
    ];
    masterIdentities = [
      {
        identity = ".age/legacy.gopass.identity.age";
      }
      {
        identity = ".age/zw.master.identity.age";
      }
      # {
      #   identity = ".age/zw.tpm.identity.age";
      # }
    ];
    storageMode = "local";
  };
}
