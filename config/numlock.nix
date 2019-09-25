{ ... }:

{
  systemd.services.numlock = {
    wantedBy = [ "multi-user.target" ];
    description = "Always keep numlock on in console.";
    serviceConfig = {
      ExecStart=/home/matt/src/tools/console-numlock.sh;
      RemainAfterExit="yes";
      StandardInput="tty";
    };
  };
}
