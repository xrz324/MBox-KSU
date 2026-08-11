#!/sbin/sh

SKIPUNZIP=1
ASH_STANDALONE=1

export PATH="/data/adb/magisk:/data/adb/ksu/bin:/data/adb/ap/bin:$PATH"

tproxy_check_chain="MBOX_CHECK_$$"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    abort "Error: Required command not found: $1"
  fi
}

check_busybox_applets() {
  local applet
  local applets="awk inotifyd nohup pidof setuidgid"

  for applet in $applets; do
    if ! busybox --list | busybox grep -qx "$applet"; then
      abort "Error: BusyBox applet not found: $applet"
    fi
  done
}

cleanup_tproxy_check() {
  iptables -w 100 -t mangle -F "$tproxy_check_chain" >/dev/null 2>&1 || true
  iptables -w 100 -t mangle -X "$tproxy_check_chain" >/dev/null 2>&1 || true
}

check_tproxy_support() {
  cleanup_tproxy_check
  iptables -w 100 -t mangle -N "$tproxy_check_chain" >/dev/null 2>&1 || return 1

  iptables -w 100 -t mangle -A "$tproxy_check_chain" -j MARK --set-mark 1 >/dev/null 2>&1 &&
    iptables -w 100 -t mangle -A "$tproxy_check_chain" -p tcp -j TPROXY --on-ip 127.0.0.1 --on-port 65535 --tproxy-mark 1 >/dev/null 2>&1 &&
    iptables -w 100 -t mangle -A "$tproxy_check_chain" -m owner --uid-owner 0 --gid-owner 3005 -j RETURN >/dev/null 2>&1 &&
    iptables -w 100 -t mangle -A "$tproxy_check_chain" -m addrtype --dst-type LOCAL -j RETURN >/dev/null 2>&1
  local result=$?

  cleanup_tproxy_check
  return "$result"
}

if [ "$BOOTMODE" != true ]; then
  abort "Error: Please install in KernelSU Manager"
fi

if [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt 26000 ]; then
  abort "Error: Please update your KernelSU"
fi

for required_command in busybox ip iptables; do
  require_command "$required_command"
done
check_busybox_applets

if ! check_tproxy_support; then
  abort "Error: This device does not provide the required TPROXY, MARK, owner UID/GID, or addrtype netfilter support"
fi
ui_print "- TProxy command and netfilter support verified"

service_dir="/data/adb/service.d"

if [ ! -d "$service_dir" ]; then
  mkdir -p "$service_dir"
fi

unzip -qo "${ZIPFILE}" -x 'META-INF/*' -d "$MODPATH"

mv "$MODPATH/box" /data/adb/
mkdir -p /data/adb/box/bin/
mkdir -p /data/adb/box/run/

mv -f "$MODPATH/mbox_service.sh" "$service_dir/"

rm -f "$MODPATH/customize.sh"

set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive /data/adb/box/ 0 0 0755 0644
set_perm_recursive /data/adb/box/scripts/ 0 0 0755 0700
set_perm_recursive /data/adb/box/bin/ 0 0 0755 0700

set_perm "$service_dir/mbox_service.sh" 0 0 0700

chmod ugo+x /data/adb/box/scripts/*
