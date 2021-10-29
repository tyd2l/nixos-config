{ config, pkgs, ... }:

{
  imports =
    [ 
      <home-manager/nixos>
	  ./userdirs.nix
    ];

  environment.systemPackages = with pkgs; [
    libnotify
 ## Network
    brave
    megasync
    tdesktop
 ## Security
    bitwarden
 ## Vulkan support
    vulkan-headers
    vulkan-tools-lunarg
    vulkan-loader
    vulkan-extension-layer
 ## Text
    libreoffice-fresh
    simplenote
 ## USB
    unetbootin
  ];
  
#### Progs configs

  home-manager.useGlobalPkgs = true;

  home-manager.users.tyd2l = { pkgs, ... }: {
  
    programs.git = {
      enable = true;
      userName  = "tyd2l";
      userEmail = "tyd2l@protonmail.ch";
    };
  };
 
  programs.adb.enable = true;
  users.users.tyd2l.extraGroups = [ "adbusers" ];
  
  services.udisks2.enable = true;
  
#### GUI
  
  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
  };
  
  hardware.opengl = {
    enable = true;
    driSupport = true;
	driSupport32Bit = true;
  };
  
  programs.xwayland.enable = true;
  
#### Virtualisation
  
#  virtualisation.virtualbox.host = {
#    enable = true;
#    enableExtensionPack = true;
#  };
# users.users.tyd2l.extraGroups = [ "vboxusers" ];
  
  virtualisation.libvirtd.enable = true;
  users.users.tyd2l.extraGroups = [ "libvirtd" ];
  
}