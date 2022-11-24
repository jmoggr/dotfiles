{pkgs, config, lib, ...}:
with pkgs;
with lib;
with builtins;
let
    cfg = config.sys;
in {
    options.sys = {
        gui = mkEnableOption "Enable GUI";
    };

    config = mkIf cfg.gui {
environment.systemPackages = with pkgs; [
    gh
    virt-manager
    dconf
    yubikey-personalization-gui
    yubikey-manager-qt
    yubikey-manager
    keepassxc
    gthumb
    libreoffice-qt
    imagemagick
    thunderbird
    jpegoptim
    desktop-file-utils
    gnucash
    zoom-us
    scrot
    chromium
    firefox
    discord
    vscode
    slack
    obsidian
    tdesktop           # telegram desktop app
    simple-scan        # runs scanner
    qpdf               # remove pdf passwords
  ];

  programs = {
    steam = {
      enable = true;
    };
    kdeconnect = {
      enable = true;
    };
    dconf = {
      enable = true;
    };
  };

  services = {
    saned.enable = true;
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns = true;
    };
    syncthing = {
      enable = true;
      user = "jason";
      dataDir = "/work/syncthing";
      configDir = "/work/syncthing/.config/syncthing";
    };
  };

  hardware = {
    sane = {
      enable = true;
      brscan5 = {
        enable = true;
      };
    };
  };



  virtualisation.libvirtd.enable = true;


  networking.networkmanager.enable = true;

  virtualisation.docker.enable = true;

    };
}