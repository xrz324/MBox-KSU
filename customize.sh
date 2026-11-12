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
  local applets="awk mkfifo nohup pidof setuidgid"

  for applet in $applets; do
    if ! busybox --list | busybox grep -qx "$applet"; then
      abort "Error: BusyBox applet not found: $applet"
    fi
  done
}

check_ip_monitor() {
  local monitor_pid

  ip monitor link address >/dev/null 2>&1 &
  monitor_pid=$!
  sleep 1
  if ! kill -0 "${monitor_pid}" >/dev/null 2>&1; then
    wait "${monitor_pid}" 2>/dev/null || true
    return 1
  fi
  kill "${monitor_pid}" >/dev/null 2>&1 || true
  wait "${monitor_pid}" 2>/dev/null || true
}

check_ss() {
  ss -H -lnt >/dev/null 2>&1 && ss -H -lnu >/dev/null 2>&1
}

cleanup_tproxy_check() {
  iptables -w 100 -t mangle -F "$tproxy_check_chain" >/dev/null 2>&1 || true
  iptables -w 100 -t mangle -X "$tproxy_check_chain" >/dev/null 2>&1 || true
  iptables -w 100 -t nat -F "$tproxy_check_chain" >/dev/null 2>&1 || true
  iptables -w 100 -t nat -X "$tproxy_check_chain" >/dev/null 2>&1 || true
  iptables -w 100 -t filter -F "$tproxy_check_chain" >/dev/null 2>&1 || true
  iptables -w 100 -t filter -X "$tproxy_check_chain" >/dev/null 2>&1 || true
  ip6tables -w 100 -t filter -F "$tproxy_check_chain" >/dev/null 2>&1 || true
  ip6tables -w 100 -t filter -X "$tproxy_check_chain" >/dev/null 2>&1 || true
}

check_tproxy_support() {
  cleanup_tproxy_check
  iptables -w 100 -t mangle -N "$tproxy_check_chain" >/dev/null 2>&1 || return 1
  if ! iptables -w 100 -t nat -N "$tproxy_check_chain" >/dev/null 2>&1; then
    cleanup_tproxy_check
    return 1
  fi
  if ! iptables -w 100 -t filter -N "$tproxy_check_chain" >/dev/null 2>&1; then
    cleanup_tproxy_check
    return 1
  fi

  ip6tables -w 100 -t filter -N "$tproxy_check_chain" >/dev/null 2>&1 &&
    ip6tables -w 100 -t filter -A "$tproxy_check_chain" -j DROP >/dev/null 2>&1 &&
    ip6tables -w 100 -t filter -C "$tproxy_check_chain" -j DROP >/dev/null 2>&1 &&
    iptables -w 100 -t filter -A "$tproxy_check_chain" -p icmp --icmp-type 3 -m conntrack --ctstate RELATED -j RETURN >/dev/null 2>&1 &&
    iptables -w 100 -t filter -A "$tproxy_check_chain" -j DROP >/dev/null 2>&1 &&
    iptables -w 100 -t filter -C "$tproxy_check_chain" -j DROP >/dev/null 2>&1 &&
    iptables -w 100 -t mangle -A "$tproxy_check_chain" -j MARK --set-xmark 268435456/268435456 >/dev/null 2>&1 &&
    iptables -w 100 -t mangle -A "$tproxy_check_chain" -p tcp -j TPROXY --on-ip 127.0.0.1 --on-port 65535 --tproxy-mark 268435456/268435456 >/dev/null 2>&1 &&
    iptables -w 100 -t mangle -A "$tproxy_check_chain" -p udp -j TPROXY --on-ip 127.0.0.1 --on-port 65535 --tproxy-mark 268435456/268435456 >/dev/null 2>&1 &&
    iptables -w 100 -t mangle -A "$tproxy_check_chain" -m owner --uid-owner 0 --gid-owner 3005 -j RETURN >/dev/null 2>&1 &&
    iptables -w 100 -t mangle -A "$tproxy_check_chain" -p tcp --syn -j CONNMARK --set-xmark 2097152/2097152 >/dev/null 2>&1 &&
    iptables -w 100 -t mangle -A "$tproxy_check_chain" -m connmark --mark 2097152/2097152 -j RETURN >/dev/null 2>&1 &&
    iptables -w 100 -t mangle -A "$tproxy_check_chain" -m mark --mark 268435456/268435456 -j RETURN >/dev/null 2>&1 &&
    iptables -w 100 -t mangle -A "$tproxy_check_chain" -m addrtype --dst-type LOCAL -j RETURN >/dev/null 2>&1 &&
    iptables -w 100 -t mangle -A "$tproxy_check_chain" -m addrtype --dst-type BROADCAST -j RETURN >/dev/null 2>&1 &&
    iptables -w 100 -t nat -A "$tproxy_check_chain" -p tcp -j REDIRECT --to-ports 65535 >/dev/null 2>&1 &&
    iptables -w 100 -t nat -A "$tproxy_check_chain" -p udp -j REDIRECT --to-ports 65535 >/dev/null 2>&1
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

for required_command in busybox ip iptables ip6tables ss; do
  require_command "$required_command"
done
check_busybox_applets
if ! check_ss; then
  abort "Error: ss does not support the required TCP and UDP listener queries"
fi
if ! check_ip_monitor; then
  abort "Error: ip monitor does not support link and address events"
fi
if ! ip -6 rule show >/dev/null 2>&1; then
  abort "Error: IPv6 policy routing queries are unavailable"
fi
if ! check_tproxy_support; then
  abort "Error: This device does not provide the required TPROXY, MARK/CONNMARK, REDIRECT, owner UID/GID, addrtype, or ICMP/conntrack netfilter support"
fi
ui_print "- TProxy, DNS redirect, and egress filter support verified"

service_dir="/data/adb/service.d"

if [ ! -d "$service_dir" ]; then
  mkdir -p "$service_dir"
fi

unzip -qo "${ZIPFILE}" -x 'META-INF/*' -d "$MODPATH"
rm -f "$MODPATH/post-fs-data.sh"

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
