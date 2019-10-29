{ pkgs, ... }:

{
  systemd.services.btrfs-snap = {
    description = "Create a snapshot of the home directory.";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = /home/matt/src/tools/btrfs-snap.sh;
      User = "root";
    };
    path = with pkgs; [
      btrfs-progs
      dateutils
    ];
  };

  systemd.timers.btrfs-snap = {
    description = "Run btrfs-snap.sh daily at midnight.";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Unit = "btrfs-snap.service";
      OnCalendar = "daily";
    };
  };
}
