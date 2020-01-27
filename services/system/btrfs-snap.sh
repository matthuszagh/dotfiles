#!/bin/sh

mkdir -p /.snapshots/home
btrfs subvolume snapshot -r /home /.snapshots/home/$(date +%Y-%m-%d)

# Remove backups older than 30 days.
for f in /.snapshots/home/*
do
    fdate=${f##*\/}
    date_diff=$(ddiff "$fdate" today)
    if [ $date_diff -gt 30 ]
    then
        btrfs subvolume delete $f
    fi
done
