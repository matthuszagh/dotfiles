{ config, pkgs, ... }:

{
  services = {
    mpd = {
      enable = true;
    };
    blueman.enable = true;
  };

  hardware = {
    bluetooth = {
     enable = true;
     config = {
       General = {
         Enable = "Source,Sink,Media,Socket";
       };
     };
    };
    pulseaudio = {
      enable = true;
      configFile = pkgs.writeText "default.pa" ''
        load-module module-bluetooth-policy
        load-module module-bluetooth-discover
        ## module fails to load with
        ##   module-bluez5-device.c: Failed to get device path from module arguments
        ##   module.c: Failed to load module "module-bluez5-device" (argument: ""): initialization failed.
        # load-module module-bluez5-device
        # load-module module-bluez5-discover
      '';
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull;
      support32Bit = true;
    };
  };

  sound.enable = true;
}
