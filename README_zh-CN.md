# Mihomo Box

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

[English](README.md) | 简体中文

用于在 Android 设备上运行 **Mihomo** 的 KernelSU 模块，支持 **TProxy**、**TUN**、热点代理，以及 TProxy 模式下的 DNS 53 端口重定向。

## 安装

1. 在 KernelSU Manager 中安装模块。
2. 下载适合设备架构的 `mihomo` 可执行文件，放至 `/data/adb/box/bin/mihomo`。
3. 按下文配置 Mihomo 和模块，然后重启设备。

安装时会自动检查必要命令和内核能力。

## 配置

- Mihomo 配置：`/data/adb/box/mihomo/config.yaml`，参见[内置配置](box/mihomo/config.yaml)。
- 模块配置：`/data/adb/box/scripts/box.config`，参见[配置参数](box/scripts/box.config)。

常用模块参数：

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `PROXY_MODE` | `tproxy` | 代理模式：`tproxy` 或 `tun` |
| `TPROXY_PORT` | `1536` | 与 Mihomo 的 `tproxy-port` 一致 |
| `DNS_PORT` | `1053` | 与 Mihomo 的 `dns.listen` 端口一致 |
| `FAKE_IP_RANGE` | `198.18.0.0/16` | 与 Mihomo 的 `dns.fake-ip-range` 网段一致 |
| `PROXY_HOTSPOT` | `1` | 开启（`1`）或关闭（`0`）热点代理 |
| `HOTSPOT_INTERFACE` | `wlan1` | 热点接口，多个接口用空格分隔 |
| `tun_device` | `mihomo` | 与 Mihomo 的 `tun.device` 一致 |

Mihomo 配置中的 `tun.enable` 应与模式对应：TProxy 模式设为 `false`，TUN 模式设为 `true`。其余模块参数通常保持默认即可。

热点代理仅覆盖 `HOTSPOT_INTERFACE` 中配置的接口。开启热点后，可用 `ip -o link` 确认实际接口；避免使用会同时匹配普通 Wi-Fi 接口的 `wlan+` 等通配写法。TProxy 热点 DNS 重定向需要 `dns.listen: 0.0.0.0:1053`，端口与 `DNS_PORT` 对应；无需开启 `allow-lan: true`。

## 使用说明

- 系统启动完成后自动运行 Mihomo。更新或停用模块、切换模式、修改规则配置后需重启；不提供运行期停止、重启命令。
- 不支持与系统 VPN 或其他透明代理同时使用。
- TProxy 规则对局域网、组播等本地用途地址直接旁路；DNS 53 重定向优先于目的地址旁路。
- IPv4 过滤会阻止未代理的公网非 TCP/UDP 流量，包括 ICMP 探测；保留局域网访问及关联连接的 ICMP 错误。
- IPv6 默认阻断，部分依赖 IPv6 的通话或网络功能可能受影响。

## 日志

- 脚本日志：`/data/adb/box/run/run.log`
- 配置检查日志：`/data/adb/box/run/check.log`
- Mihomo 错误输出：`/data/adb/box/run/error_mihomo.log`

## 卸载

卸载会移除自启动脚本，保留 `/data/adb/box` 及其中数据。卸载后需重启设备。

## 许可证

本项目基于 [GNU General Public License v3.0](LICENSE) 发布。
