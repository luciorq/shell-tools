#!/usr/bin/env bash

# NOTE: Highly distructive script, make sure to read and understant it before running

ZPOOL_NAME="datahomes"

# NOTE: /dev/sdc* was specific for this machine, change it before running
DISK_WWN_ID="$(\ls -l /dev/disk/by-id/ | \grep 'sdc$' | \awk '{print $9}' | \grep '^wwn')"

\sudo zpool create "${ZPOOL_NAME}" "${DISK_WWN_ID}";
\sudo zfs set compression=zstd "${ZPOOL_NAME}";
\sudo zfs set acltype=posixacl "${ZPOOL_NAME}";
\sudo zfs set xattr=sa "${ZPOOL_NAME}";
\sudo zfs set atime=off "${ZPOOL_NAME}";
#zfs set relatime=off "${ZPOOL_NAME}";
\sudo zfs set autoexpand=on "${ZPOOL_NAME}";
\sudo zfs set redundant_metadata=most "${ZPOOL_NAME}";
\sudo zfs set mountpoint=/tmp_home "${ZPOOL_NAME}";

# Copy files from old home to the temporary home dir
\sudo mount -a;
\sudo rsync -avhP --delete --info=progress2 /home /tmp_home;

\sudo mv /home /old_home;

# After transfering the actual files
\sudo zfs set mountpoint=/home "${ZPOOL_NAME}";

\sudo rm -rf /old_home;
