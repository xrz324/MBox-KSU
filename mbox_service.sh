#!/sbin/sh

export PATH="/data/adb/magisk:/data/adb/ksu/bin:/data/adb/ap/bin:$PATH"

module_dir="/data/adb/modules/mbox"

[ -n "$(magisk -v 2> /dev/null | grep lite)" ] && module_dir=/data/adb/lite_modules/mbox

scripts_dir="/data/adb/box/scripts"

(
  until [ "$(getprop sys.boot_completed 2> /dev/null)" = "1" ]; do
    sleep 3
  done
  "${scripts_dir}/start.sh"
)&

if command -v inotifyd > /dev/null 2>&1; then
  inotifyd "${scripts_dir}/box.inotify" "${module_dir}" > /dev/null 2>&1 &
elif command -v busybox > /dev/null 2>&1 && busybox --list 2> /dev/null | grep -qx inotifyd; then
  busybox inotifyd "${scripts_dir}/box.inotify" "${module_dir}" > /dev/null 2>&1 &
fi
