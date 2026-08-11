#!/system/bin/sh

module_dir="/data/adb/modules/mbox"

[ -n "$(magisk -v 2>/dev/null | grep lite)" ] && module_dir=/data/adb/lite_modules/mbox

scripts_dir=$(dirname "$0")

bin_name="mihomo"
box_path="/data/adb/box"
run_path="${box_path}/run"
pid_file="${run_path}/${bin_name}.pid"

rm -f "${pid_file}"
mkdir -p "${run_path}"

if [ ! -f "${module_dir}/disable" ]; then
  : >"${run_path}/run.log"

  if ! ip -6 rule show 2>/dev/null | grep -q '^1:.*unreachable'; then
    ip -6 rule add unreachable pref 1 >/dev/null 2>&1 || true
  fi

  "${scripts_dir}/box.service" start >>/dev/null 2>>"${run_path}/run.log"
fi
