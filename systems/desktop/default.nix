{ nixpkgs, ... }:  {

        inherit nixpkgs;
        name = "nixos";
        system = "x86_64-linux";
        modules = [
          ../../base
          ./hardware-configuration.nix
          ./zfs.nix
          ../../hardware
        ];
        cfg = {
          sys.hardware.audio = false;
          sys.hardware.graphics.primaryGPU = "none";
          sys.gui = false;
        };
      }