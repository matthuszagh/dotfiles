{ config, pkgs, ... }:

{
  services.xserver = {
    # Enable touchpad support.
    libinput.enable = true;
    libinput.tapping = false;
    libinput.disableWhileTyping = true;

    enable = true;
    layout = "us";
    xkbOptions = "ctrl:swapcaps";

    enableCtrlAltBackspace = true;

    # remote connections
    enableTCP = true;
  };
}
