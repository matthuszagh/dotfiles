{ pkgs, ... }:

{
  systemd.services.btrfs-backup = {
    description = "Create a backup of the home directory.";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = /home/matt/src/dotfiles/sysd/root/btrfs-backup.sh;
      User = "root";
    };
    path = with pkgs; [
      btrfs-progs
      dateutils
    ];
  };

  systemd.timers.btrfs-backup = {
    description = "Run btrfs-backup.sh immediately after btrfs-snap.";
    after = [ "btrfs-snap.timer" ];
  };
}
