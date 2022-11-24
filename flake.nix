{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
  };
  
  outputs = { nixpkgs, ... }:
  let
    lib = import ./lib;
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };

    wrapper = name : lib.mkNixOSConfig (import ./systems/${name} { inherit nixpkgs; });

  in {
    nixosConfigurations = {
      nixos = wrapper "vm";
    };
  };
}
