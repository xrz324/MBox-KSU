# Mihomo Box

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

[English](README.md) | 简体中文

本模块用于在 Android 设备上启动 **Mihomo**，通过 **TProxy** 或 **TUN** 接管设备流量。TProxy 实现额外支持热点代理和 DNS 53 端口劫持。

## 安装

1. 在 KernelSU Manager 中安装模块
2. 下载合适的 `mihomo` 可执行文件放至：`/data/adb/box/bin/mihomo`
3. 编辑配置文件：`/data/adb/box/mihomo/config.yaml`

安装脚本会检查必要命令和所需内核能力，任一能力缺失即会拒绝安装。

## 配置

- Mihomo 配置：`/data/adb/box/mihomo/config.yaml`
- 模块脚本配置：`/data/adb/box/scripts/box.config`
  - `CORE_USER_GROUP`：默认 `root:net_admin`。`xt_owner` 同时匹配 UID 和 socket 主 GID，因此其他仅附加 `net_admin` 组的进程不会旁路
  - `TPROXY_RULE_PREF`：策略路由规则优先级，必须小于 `10000`，否则会排在 Android netd 规则之后导致 TProxy 失效
  - `TPROXY_MARK`：TProxy 的高位路由签名。模块以 `0xffffffff` 全宽覆盖并匹配该 mark，不保留原字段
  - `DNS_PORT`：需与 `dns.listen` 中的端口一致；热点 DNS 重定向要求监听地址为 `0.0.0.0`
- 状态检查命令：`/data/adb/box/scripts/box.service status`

## 提示

`HOTSPOT_INTERFACE` 应填**具体 AP 接口**。`wlan+` 通配会同时命中手机 WiFi，同网段主机可能借道代理。实际接口名应在开启热点后用 `ip -o link` 确认。

热点代理不要求 `allow-lan: true`。TProxy 规则使用 `--on-ip 127.0.0.1` 将查找地址固定在回环上，无须端口对外可见。

本地、回环、广播、组播、未指定地址、RFC 1918 私网、`100.64.0.0/10` 共享地址及 `169.254.0.0/16` 链路本地地址在 TCP/UDP 内核规则中直接旁路，不进入 Mihomo。DNS 53 重定向先于目的地址旁路；其他保留单播地址仍交由 Mihomo 决策。

模块不支持与系统 VPN 或其他透明代理同时使用。系统启动完成后立即装载 TProxy 规则，再启动 Mihomo；Mihomo 异常时，已接管流量会直接失败，不会回退直连。TProxy 模式等待透明代理监听，TUN 模式等待配置的 TUN 设备。仅在 TProxy 模式下，TCP/UDP 53 才通过 NAT 直接重定向到 Mihomo DNS 监听端口，两种模式都会限制 DNS 监听端口只接受本机回环与配置的热点接口流量。模块不提供运行期停止或重启功能；停用模块或修改运行模式及规则配置后，应重启设备。

IPv6 在启动后通过各接口的 `disable_ipv6` 禁用，具有 IPv6 地址且没有 IPv4 地址的 `rmnet*` 接口视为 IMS 承载并排除；尚未分配地址的 `rmnet*` 不被处理。`ip monitor link address` 在接口或地址变化后触发重扫；事件会先短暂合并，并对 netd 重建接口期间的瞬时写入失败静默重试。禁用或卸载模块后重启设备，内核网络状态会随重启清除。

TProxy 标记设计参考 [Linux 内核透明代理文档](https://docs.kernel.org/networking/tproxy.html)、[AOSP Fwmark 定义](https://android.googlesource.com/platform/system/netd/+/master/include/Fwmark.h) 与 [Xray 的 GID 防环实践](https://xtls.github.io/document/level-2/iptables_gid.html)。核心进程通过 UID 0 与主 GID `net_admin` 的组合在 `OUTPUT` 中旁路，不依赖 socket mark。

## 日志

- 脚本日志：`/data/adb/box/run/run.log`
- 配置检查日志：`/data/adb/box/run/check.log`
- Mihomo 错误输出：`/data/adb/box/run/error_mihomo.log`

## 卸载

- 卸载模块会移除 service 脚本，但保留 `/data/adb/box` 数据目录；卸载后需重启设备。

## 许可证

本项目基于 [GNU General Public License v3.0](LICENSE) 发布。
