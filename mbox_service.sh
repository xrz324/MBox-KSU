#!/sbin/sh

export PATH="/data/adb/magisk:/data/adb/ksu/bin:/data/adb/ap/bin:$PATH"

scripts_dir="/data/adb/box/scripts"

(
  until [ "$(getprop sys.boot_completed 2>/dev/null)" = "1" ]; do
    sleep 1
  done
  "${scripts_dir}/start.sh"
) &
