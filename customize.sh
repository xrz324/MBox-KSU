#!/sbin/sh

SKIPUNZIP=1
ASH_STANDALONE=1

if [ "$BOOTMODE" ! = true ] ; then
  abort "Error: Please install in KernelSU Manager"
fi

if [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt 10670 ] ; then
  abort "Error: Please update your KernelSU"
fi

if [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt 10683 ] ; then
  service_dir="/data/adb/ksu/service.d"
else
  service_dir="/data/adb/service.d"
fi

if [ ! -d "$service_dir" ] ; then
    mkdir -p $service_dir
fi

unzip -qo "${ZIPFILE}" -x 'META-INF/*' -d $MODPATH

if [ -d /data/adb/box ] ; then
  [ -x /data/adb/box/scripts/box.service ] && /data/adb/box/scripts/box.service stop > /dev/null 2>&1

  old_core_user_group="$(grep -E '^[[:space:]]*CORE_USER_GROUP=' /data/adb/box/scripts/box.config 2> /dev/null | tail -n 1 | sed 's/^[[:space:]]*//')"

  cp /data/adb/box/scripts/box.config /data/adb/box/scripts/box.config.bak 2> /dev/null
  ui_print "- Old box.config backed up to box.config.bak"

  if [ -n "${old_core_user_group}" ]; then
    sed -i "s/^CORE_USER_GROUP=.*/${old_core_user_group}/" "$MODPATH/box/scripts/box.config"
    ui_print "- CORE_USER_GROUP migrated: ${old_core_user_group}"
  fi

  cp -f $MODPATH/box/scripts/* /data/adb/box/scripts/
  rm -rf $MODPATH/box
else
  mv $MODPATH/box /data/adb/
fi

mkdir -p /data/adb/box/bin/
mkdir -p /data/adb/box/run/

mv -f $MODPATH/mbox_service.sh $service_dir/

rm -f customize.sh

set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive /data/adb/box/ 0 0 0755 0644
set_perm_recursive /data/adb/box/scripts/ 0 0 0755 0700
set_perm_recursive /data/adb/box/bin/ 0 0 0755 0700

set_perm $service_dir/mbox_service.sh 0 0 0700

# fix "set_perm_recursive /data/adb/box/scripts" not working on some phones.
chmod ugo+x /data/adb/box/scripts/*

for pid in $(pidof inotifyd 2> /dev/null); do
  if grep -q "box\\.inotify" "/proc/${pid}/cmdline" 2> /dev/null; then
    kill "${pid}" 2> /dev/null
  fi
done

inotifyd "/data/adb/box/scripts/box.inotify" "$MODPATH" > /dev/null 2>&1 &
