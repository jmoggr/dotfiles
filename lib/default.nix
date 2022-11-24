    
with builtins;
rec {
mkNixOSConfig = {name, nixpkgs,  system, stateVersion ? "22.05", modules ? [../modules], cfg ? {}, ...}: let

  in nixpkgs.lib.nixosSystem {
    inherit system;

    modules = [
      cfg
      {
        imports = modules;

        system.stateVersion = stateVersion;
        networking.hostName = "${name}";
      }
    ];
  };
}