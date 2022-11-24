{ config, pkgs, ... }:

{
    services.openssh.enable = true;
    services.openssh.passwordAuthentication = true;
        system.stateVersion = "22.05";


    environment.systemPackages = with pkgs; [
        htop
        iotop
        git
        killall
        wget
        curl
        bind
        killall
        parted
        zip
        unzip
        unrar
        zip
        p7zip
        git-crypt
        inxi
        usbutils
        vscode
nodejs-16_x
        zfs
    ];

  users.users.jason = {
    isNormalUser = true;
    description = "Jason";
    extraGroups = [ "networkmanager" "wheel" "docker" "scanner" "lp" "libvirtd" ];
    hashedPassword = "$6$FR.6QSSwO7cgpPC0$6P3Z3fEEpXL09n7esnv42PoPqng6c48iEA3pTsl2254sau1wjGUxwE6c6SkG9wu5.D4HD2RRhEOXQz6i3tVFy.";
  };

}
