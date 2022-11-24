{pkgs, config, lib, ...}:
with pkgs;
with lib;
with builtins;
let
    cfg = config.sys;
in {
    options.sys.hardware = {
        audio = mkEnableOption "Enable audio";
    };

    config = mkIf cfg.hardware.audio {
        sys.software = [
            pulseaudio
        ];

        security.rtkit.enable = true;

        services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
        };
    };
}
