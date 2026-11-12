# Mihomo Box

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

English | [简体中文](README_zh-CN.md)

An Android KernelSU module for running **Mihomo**. It supports **TProxy** and
**TUN**, hotspot proxying, and DNS port 53 redirection in TProxy mode.

## Installation

1. Install the module in KernelSU Manager.
2. Download the `mihomo` executable for your device's architecture and place it at
   `/data/adb/box/bin/mihomo`.
3. Configure Mihomo and the module as described below, then reboot.

The installer automatically checks the required commands and kernel capabilities.

## Configuration

- Mihomo configuration: `/data/adb/box/mihomo/config.yaml` — [included configuration](box/mihomo/config.yaml).
- Module configuration: `/data/adb/box/scripts/box.config` — [available settings](box/scripts/box.config).

Common module settings:

| Setting | Default | Description |
| --- | --- | --- |
| `PROXY_MODE` | `tproxy` | Proxy mode: `tproxy` or `tun` |
| `TPROXY_PORT` | `1536` | Match Mihomo's `tproxy-port` |
| `DNS_PORT` | `1053` | Match the port in Mihomo's `dns.listen` |
| `FAKE_IP_RANGE` | `198.18.0.0/16` | Match the subnet of Mihomo's `dns.fake-ip-range` |
| `PROXY_HOTSPOT` | `1` | Enable (`1`) or disable (`0`) hotspot proxying |
| `HOTSPOT_INTERFACE` | `wlan1` | Hotspot interfaces, separated by spaces |
| `tun_device` | `mihomo` | Match Mihomo's `tun.device` |

Set Mihomo's `tun.enable` to `false` for TProxy mode or `true` for TUN mode.
Other module settings can usually remain at their defaults.

Hotspot proxying covers only the interfaces in `HOTSPOT_INTERFACE`. Enable the
hotspot and use `ip -o link` to confirm its interface; avoid broad wildcards
such as `wlan+`, which also match the phone's Wi-Fi interface. TProxy hotspot
DNS redirection requires `dns.listen: 0.0.0.0:1053` (adjust the port to match
`DNS_PORT`). Hotspot proxying does not require `allow-lan: true`.

## Usage notes

- Mihomo starts automatically after Android finishes booting. Reboot after
  updating or disabling the module, switching modes, or changing rule settings;
  runtime stop and restart commands are not provided.
- Using this module with a system VPN or another transparent proxy is not supported.
- TProxy rules bypass local destinations, including LAN and multicast addresses.
  DNS port 53 redirection takes precedence over destination bypasses.
- IPv4 filters block unproxied public non-TCP/UDP traffic, including ICMP probes,
  while allowing local-network traffic and connection-related ICMP errors.
- IPv6 is blocked by default, which may affect calls or other network features
  that depend on IPv6.

## Logs

- Script log: `/data/adb/box/run/run.log`
- Configuration check log: `/data/adb/box/run/check.log`
- Mihomo error output: `/data/adb/box/run/error_mihomo.log`

## Uninstallation

Uninstalling removes the startup script but preserves `/data/adb/box` and its
data. Reboot after uninstalling.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).
