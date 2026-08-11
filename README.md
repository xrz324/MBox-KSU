# Box KernelSU

本模块借鉴了 [CHIZI-0618 的 box4magisk](https://github.com/CHIZI-0618/box4magisk)，用于在 Android 设备上启动 **Mihomo**，通过 **TProxy** 或 **TUN** 接管设备流量。TProxy 实现只保留热点代理，分应用策略交由核心处理，不包含 REDIRECT、应用白/黑名单、MAC 过滤、IPSet、国内 IP 绕过等额外功能。

## 安装

1. 在 KernelSU Manager 中安装模块
2. 下载合适的 `mihomo` 可执行文件放至：`/data/adb/box/bin/mihomo`
3. 编辑配置文件：`/data/adb/box/mihomo/config.yaml`

安装脚本会检查必要命令和所需内核能力，任一能力缺失即会拒绝安装。

## 配置

- Mihomo 配置：`/data/adb/box/mihomo/config.yaml`
- 模块脚本配置：`/data/adb/box/scripts/box.config`
  - `TPROXY_RULE_PREF`：策略路由规则优先级，必须小于 `10000`，否则会排在 Android netd 规则之后导致 TProxy 静默失效
  - `FAKE_IP_RANGE`：需与 Mihomo 的 `dns.fake-ip-range` 一致；该网段的 ICMP 会被重定向到本机，使 `ping` 有响应。未使用 fake-ip 时留空即可
- 手动管理命令：`/data/adb/box/scripts/box.service start|stop|restart|status`

## 提示

`HOTSPOT_INTERFACE` 应填**具体 AP 接口**。`wlan+` 通配会同时命中手机 WiFi，同网段主机可能借道代理。实际接口名可在开启热点后用 `ip -o link` 确认。

热点代理不要求 `allow-lan: true`。TProxy 规则使用 `--on-ip 127.0.0.1` 将查找地址固定在回环上，无须端口对外可见。

## 日志

- 脚本日志：`/data/adb/box/run/run.log`
- 配置检查日志：`/data/adb/box/run/check.log`
- Mihomo 错误输出：`/data/adb/box/run/error_mihomo.log`

## 卸载

- 卸载模块会移除 service 脚本，但保留 `/data/adb/box` 数据目录。
