{pkgs, config, lib, ...}:
{
    imports = [
        ./scripts.nix
        ./base.nix
        ./core.nix
        ./syst.nix
        ./nix.nix
    ];

}