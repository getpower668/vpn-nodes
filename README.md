# VPN-Auto 节点订阅

本仓自动同步抓取的免费节点，供 v2rayNG / Clash / sing-box 等客户端订阅。

## 订阅 URL

| 来源 | URL | 备注 |
|---|---|---|
| **jsdelivr CDN（推荐，国内快）** | https://cdn.jsdelivr.net/gh/getpower668/vpn-nodes@main/free-nodes-subscription.b64 | 自动缓存，30 分钟生效 |
| GitHub raw（兜底） | https://raw.githubusercontent.com/getpower668/vpn-nodes/main/free-nodes-subscription.b64 | 国内偶尔慢但稳 |

## 客户端使用

### VPN-Auto（**推荐**）
装我编好的 [VPN-Auto-2.2.5-arm64-v8a.apk](../outputs/VPN-Auto-2.2.5-arm64-v8a.apk)，
它已经把 jsdelivr URL 写进 BuildConfig，**打开 app 自动拉节点**。

### 其他客户端
订阅设置里填 jsdelivr URL 即可。

## 文件

- ree-nodes-subscription.b64 — 节点列表 base64（v2ray 订阅标准格式）
- ree-nodes-combined.txt — 明文节点，每行一个 share link

## 更新频率

每 24h 自动 push 一次（PC 端计划任务 VPN-Nodes-DailyRefresh）。