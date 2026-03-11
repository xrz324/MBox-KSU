#!/system/bin/sh

[ -x /data/adb/box/scripts/box.service ] && /data/adb/box/scripts/box.service stop > /dev/null 2>&1

rm -f /data/adb/service.d/mbox_service.sh
rm -f /data/adb/ksu/service.d/mbox_service.sh
