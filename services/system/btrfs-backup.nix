{ pkgs, ... }:

{
  systemd.services.btrfs-backup = {
    description = "Create a backup of the home directory.";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = /home/matt/src/dotfiles/services/system/btrfs-backup.sh;
      User = "root";
    };
    path = with pkgs; [
      btrfs-progs
      dateutils
    ];
  };

  systemd.timers.btrfs-backup = {
    description = "Run btrfs-backup.sh immediately after btrfs-snap.";
    wantedBy = [ "timers.target" ];
    after = [ "btrfs-snap.timer" ];
    requires = [ "btrfs-snap.timer" ];
  };
}
