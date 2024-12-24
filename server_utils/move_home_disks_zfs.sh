/usr/bin/env bash

ZPOOL_NAME="datahomes"
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


# Copiar arquivos da Home antiga para a home temporarario
\sudo mount -a;
\sudo rsync -avhP --delete --info=progress2 /home /tmp_home;

\sudo mv /home /old_home;

# After transfering the actual files
\sudo zfs set mountpoint=/home "${ZPOOL_NAME}";

\sudo rm -rf /old_home;
