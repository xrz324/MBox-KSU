# Mihomo Box

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

English | [简体中文](README_zh-CN.md)

This module runs **Mihomo** on Android devices and routes device traffic through
either **TProxy** or **TUN**. The TProxy implementation additionally supports
hotspot proxying and DNS port 53 interception.

## Installation

1. Install the module in KernelSU Manager.
2. Download the appropriate `mihomo` executable and place it at
   `/data/adb/box/bin/mihomo`.
3. Edit the configuration file at `/data/adb/box/mihomo/config.yaml`.

The installer checks all required commands and kernel capabilities. Installation
is rejected if any requirement is missing.

## Configuration

- Mihomo configuration: `/data/adb/box/mihomo/config.yaml`
- Module script configuration: `/data/adb/box/scripts/box.config`
  - `CORE_USER_GROUP`: defaults to `root:net_admin`. Because `xt_owner`
    matches both the UID and the socket's primary GID, processes that only have
    `net_admin` as a supplementary group do not bypass the proxy.
  - `TPROXY_RULE_PREF`: policy routing rule priority. It must be below
    `10000`; otherwise, it is ordered after Android netd rules and TProxy does
    not work.
  - `TPROXY_MARK`: high-bit routing signature used by TProxy. The module
    overwrites and matches the mark across the full `0xffffffff` mask without
    preserving existing fields.
  - `DNS_PORT`: must match the port in `dns.listen`. Hotspot DNS redirection
    requires the listening address to be `0.0.0.0`.
- Status command: `/data/adb/box/scripts/box.service status`

## Notes

`HOTSPOT_INTERFACE` must specify the actual AP interface. The `wlan+`
wildcard can also match the phone's Wi-Fi interface, potentially allowing hosts
on the same network to route through the proxy. Enable the hotspot and use
`ip -o link` to identify the actual interface name.

Hotspot proxying does not require `allow-lan: true`. TProxy rules use
`--on-ip 127.0.0.1` to pin the lookup address to loopback, so the port does
not need to be externally visible.

Local, loopback, broadcast, multicast, unspecified, RFC 1918 private,
`100.64.0.0/10` shared, and `169.254.0.0/16` link-local addresses bypass
Mihomo directly in the TCP/UDP kernel rules. DNS port 53 redirection takes
precedence over destination-address bypass rules; other reserved unicast
addresses are still passed to Mihomo for policy decisions.

The module cannot be used together with a system VPN or another transparent
proxy. After Android finishes booting, it installs the TProxy rules immediately
and then starts Mihomo. If Mihomo fails, intercepted traffic fails rather than
falling back to a direct connection. TProxy mode waits for the transparent
proxy listener, while TUN mode waits for the configured TUN device. Only
TProxy mode redirects TCP/UDP port 53 through NAT to the Mihomo DNS listener;
both modes restrict the DNS listener to traffic from local loopback and the
configured hotspot interface. The module does not provide runtime stop or
restart operations. Reboot the device after disabling the module or changing
its operating mode or rule configuration.

IPv6 is disabled after startup through each interface's `disable_ipv6`
setting. An `rmnet*` interface with an IPv6 address but no IPv4 address is
treated as an IMS bearer and excluded; an `rmnet*` interface without an
assigned address is not processed. `ip monitor link address` triggers a
rescan after interface or address changes. Events are briefly coalesced, and
transient write failures while netd rebuilds interfaces are retried silently.
After disabling or uninstalling the module, reboot the device to clear the
kernel network state.

The TProxy mark design references the
[Linux kernel transparent proxy documentation](https://docs.kernel.org/networking/tproxy.html),
the [AOSP Fwmark definition](https://android.googlesource.com/platform/system/netd/+/master/include/Fwmark.h),
and [Xray's GID-based loop prevention practice](https://xtls.github.io/document/level-2/iptables_gid.html).
The core process bypasses `OUTPUT` through the combination of UID 0 and
primary GID `net_admin`, without relying on a socket mark.

## Logs

- Script log: `/data/adb/box/run/run.log`
- Configuration check log: `/data/adb/box/run/check.log`
- Mihomo error output: `/data/adb/box/run/error_mihomo.log`

## Uninstallation

- Uninstalling the module removes the service script but preserves the
  `/data/adb/box` data directory. Reboot the device after uninstalling.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).
