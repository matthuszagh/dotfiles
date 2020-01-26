#!/bin/sh

SNAPSHOT_DIR=/.snapshots/home
BACKUP_DIR=/.backup/home

if [ -d "$BACKUP_DIR" ]; then
    lastsnap="$SNAPSHOT_DIR/$(ls -r "$SNAPSHOT_DIR/" | head -1)"
    lastbackup="$SNAPSHOT_DIR/$(ls -r "$BACKUP_DIR/" | head -1)"
    basename=$(basename $last_backup)
    lastsnap2="$SNAPSHOT_DIR/$basename"

    btrfs send -p $lastsnap2 $lastsnap | btrfs receive $BACKUP_DIR

    # Remove backups older than 30 days.
    for f in "$BACKUP_DIR/*"
    do
        fdate=${f##*\/}
        date_diff=$(ddiff "$fdate" today)
        if [ $date_diff -gt 30 ]
        then
            btrfs subvolume delete $f
        fi
    done
else
    mkdir -p $BACKUP_DIR
    lastf="$SNAPSHOT_DIR/$(ls -r "$SNAPSHOT_DIR/" | head -1)"
    btrfs send $lastf | btrfs receive $BACKUP_DIR
fi
