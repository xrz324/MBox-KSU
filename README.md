# Box KernelSU

本模块借鉴了 [CHIZI-0618 的 box4magisk](https://github.com/CHIZI-0618/box4magisk)，用于在 Android 设备上以系统级方式启动 **Mihomo**，通过 **TUN** 接管设备流量。因仅保留了 TUN 模式，为便于日后修改未进行Fork，在此致歉并感谢原项目的付出。

## 安装

1. 在 KernelSU Manager 中安装模块
2. 下载合适的 `mihomo` 可执行文件放至：`/data/adb/box/bin/mihomo`
3. 编辑配置文件：`/data/adb/box/mihomo/config.yaml`

## 配置

- Mihomo 配置：`/data/adb/box/mihomo/config.yaml`
    - 必须启用 `tun.enable: true`
    - 必须启用 `auto-route: true`
- 模块脚本配置：`/data/adb/box/scripts/box.config`
    - `CORE_USER_GROUP`：Mihomo 运行的用户组（默认 `root:net_admin`）
    - `tun_device`：TUN 网卡名（需与 `config.yaml` 的 `tun.device` 一致）
- 手动管理命令：`/data/adb/box/scripts/box.service start|stop|restart|status`

## 日志

- 脚本日志：`/data/adb/box/run/run.log`
- 配置检查日志：`/data/adb/box/run/check.log`
- Mihomo 错误输出：`/data/adb/box/run/error_mihomo.log`

## 卸载

- 卸载模块会移除 service 脚本，但保留 `/data/adb/box` 数据目录。
