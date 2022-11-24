{pkgs, lib, config, ...}:
with pkgs;
with lib;
with builtins;
let
    cfg = config.sys;
in {
    options.sys.hardware.graphics = {
        primaryGPU = mkOption {
          type = types.enum [ "amd" "intel" "nvidia" "none"];
          default = "none";
          description = "The primary gpu on your system that you want your desktop to display on";
        };
   };

  config = let
    gfx = cfg.hardware.graphics;

    amd = gfx.primaryGPU == "amd";
    intel = gfx.primaryGPU == "intel";
    nvidia = gfx.primaryGPU == "nvidia";

    headless = gfx.primaryGPU == "none";
  in {
    boot.initrd.kernelModules = [
      (mkIf amd "amdgpu")
    ];

    hardware.nvidia.package = mkIf nvidia config.boot.kernelPackages.nvidiaPackages.stable;
    
    services.xserver = mkIf (!headless) {
      videoDrivers = [
        (mkIf amd "amdgpu") 
        (mkIf intel "intel")
        (mkIf nvidia "nvidia")
      ];

      deviceSection = mkIf (intel || amd) ''
        Option "TearFree" "true"
      '';

      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
      layout = "us";
      xkbVariant = "";
      
      libinput.enable = true;
    };


    hardware.nvidia.modesetting.enable = nvidia;
    hardware.opengl.enable = !headless;
    hardware.opengl.driSupport = !headless;
    hardware.opengl.driSupport32Bit = !headless;
    hardware.steam-hardware.enable = !headless;

    hardware.opengl.extraPackages = mkIf (!headless) (with pkgs;[
      (mkIf intel intel-media-driver)
      (mkIf intel vaapiIntel)
      (mkIf intel vaapiVdpau)
    ]);

    sys.software = with pkgs; [
      (mkIf (!headless) glxinfo)
      (mkIf amd radeontop)
   ];
  };
}
