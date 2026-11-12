#!/system/bin/sh

module_dir="/data/adb/modules/mbox"

if magisk -v 2>/dev/null | grep -q lite; then
  module_dir=/data/adb/lite_modules/mbox
fi

scripts_dir=$(dirname "$0")

bin_name="mihomo"
box_path="/data/adb/box"
run_path="${box_path}/run"
pid_file="${run_path}/${bin_name}.pid"

mkdir -p "${run_path}"

# Discard process identities and the monitor FIFO left by the previous boot.
rm -f "${pid_file}" \
  "${run_path}/ipv6_monitor.runtime" \
  "${run_path}/ipv6_monitor.fifo" >/dev/null 2>&1 || true

if [ ! -f "${module_dir}/disable" ]; then
  : >"${run_path}/run.log"

  "${scripts_dir}/box.service" start >>/dev/null 2>>"${run_path}/run.log"
fi
