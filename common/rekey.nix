{pkgs, ...}: {
  age.rekey = {
    agePlugins = [pkgs.age-plugin-gopass];
    masterIdentities = [
      {
        identity = ".age/legacy.gopass.identity.age";
      }
      {
        identity = ".age/zw.master.identity.age";
      }
    ];
    storageMode = "local";
  };
}
