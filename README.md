# VPN-Nodes Pipeline (refresh / probe / select)

主入口: `refresh-nodes.ps1` (定时任务 `VPN-Nodes-DailyRefresh` 每天 04:00 跑一次)

## 流水线

```
[1] fetch    -> outputs/raw/*.txt           (jsdelivr CDN, 4 公开源)
[2] dedup    -> outputs/_pool-merged.txt    (906+ 唯一节点)
[3] probe    -> outputs/quality-report.json (TCP 探活 + RTT)
[4] select   -> outputs/free-nodes-*.b64    (按地区分桶, 排序, 截断)
[5] sync+push -> gh-subscription/  +  GitHub
```

## 新增 / 重写文件

| 文件 | 角色 |
|---|---|
| `probe-nodes.ps1` | TCP 探活 + RTT, 50 并发, 每节点 2 次取最小 |
| `select-nodes.ps1` | 地区识别 + 分桶 + RTT 排序 + 上限 |
| `refresh-nodes.ps1` | 主入口 (5 步流水线, 修了原版的重复块 bug) |
| `outputs/quality-report.json` | per-node 结构化探活结果 |
| `outputs/quality-report-summary.json` | 汇总 (按协议) |
| `outputs/quality-history.jsonl` | 追加, 每次跑一行摘要 |
| `outputs/regions.json` | 按 region / bucket 统计 |

## 订阅产物 (地区分桶)

| 文件 | 内容 | RTT 上限 | 单桶上限 |
|---|---|---|---|
| `free-nodes-subscription.b64` | 主订阅: 全部 alive, 按地区优先级 + RTT 排序 | - | - |
| `free-nodes-combined.txt` | 同上, 文本版 | - | - |
| `free-nodes-sea.b64` | 东南亚: SG/MY/TH/VN/PH/ID/KH/LA/MM/BN | 350ms | 80 |
| `free-nodes-neasia.b64` | 东北亚: JP/KR/TW/HK/MO | 300ms | 80 |
| `free-nodes-asia.b64` | 亚洲综合: SEA + NE-Asia + S-Asia | 350ms | - |
| `free-nodes-eu.b64` | 欧洲 | 450ms | 80 |
| `free-nodes-na.b64` | 北美: US/CA/MX | 400ms | 80 |
| `free-nodes-oc.b64` | 大洋洲: AU/NZ | 450ms | 80 |
| `free-nodes-me.b64` | 中东 | 500ms | 80 |
| `free-nodes-sa-asia.b64` | 南亚: IN/PK/BD/LK/NP | 400ms | 80 |
| `free-nodes-sa.b64` | 南美: BR/AR/CL/CO/PE | 550ms | 80 |
| `free-nodes-other.b64` | 无法识别地区 | - | 80 |

### 客户端 URL 模板

⚠️ 国内 jsdelivr 经常被 GFW RST, 拉不到数据时请改用 GitHub raw 直连 + gh-proxy 镜像.

**主订阅 (推荐 gh-proxy, 国内 100% 可达):**
```
https://gh-proxy.com/raw.githubusercontent.com/getpower668/vpn-nodes/main/free-nodes-subscription.b64
```
**备用 1 - GitHub raw 直连 (国外网络):**
```
https://raw.githubusercontent.com/getpower668/vpn-nodes/main/free-nodes-subscription.b64
```
**备用 2 - jsdelivr (国内有时被 GFW RST):**
```
https://cdn.jsdelivr.net/gh/getpower668/vpn-nodes@main/free-nodes-subscription.b64
```

**地区桶 (同样替换前缀):**
- 东南亚: `https://gh-proxy.com/raw.githubusercontent.com/getpower668/vpn-nodes/main/free-nodes-sea.b64`
- 亚洲综合: `https://gh-proxy.com/raw.githubusercontent.com/getpower668/vpn-nodes/main/free-nodes-asia.b64`
- 东北亚: `https://gh-proxy.com/raw.githubusercontent.com/getpower668/vpn-nodes/main/free-nodes-neasia.b64`

## 参数 (refresh-nodes.ps1)

    -SkipPush     跳过 GitHub 推送
    -SkipProbe    跳过探活, 用上次的 quality-report.json
    -DryRun       干跑, fetch + select 不写盘

参数 (probe-nodes.ps1):

    -InputFile        默认 outputs/free-nodes-combined.txt
    -OutputJson       默认 outputs/quality-report.json
    -Concurrency      默认 50
    -TcpTimeoutMs     默认 3000
    -ProbesPerNode    默认 2 (取最小 RTT)

参数 (select-nodes.ps1):

    -ReportJson       默认 outputs/quality-report.json
    -OutDir           默认 outputs/
    -PerRegionCap     默认 80
    -SeaMaxRttMs      默认 350
    -NeAsiaMaxRttMs   默认 300
    -AsiaMaxRttMs     默认 350
    -EuMaxRttMs       默认 450
    -NaMaxRttMs       默认 400
    -OcMaxRttMs       默认 450
    -MeMaxRttMs       默认 500
    -SaMaxRttMs       默认 550
    -SaAsiaMaxRttMs   默认 400
    -DryRun           不写盘

## 调度

定时任务 `VPN-Nodes-DailyRefresh` -> `refresh-nodes.ps1`
- 触发: 每天 04:00
- 流水线总时长: 预计 30-60s (含 1 fetch + 1 probe + 1 select + 1 push)
- 失败策略: 任一步失败立即 abort, 不发布坏订阅

## 支持协议

vmess / vless / trojan / ss (含 base64 SIP002 + 整段 base64) / hy2 / hysteria2 / tuic
IPv6 字面量 `[ipv6]:port` 已支持

## 已知限制

1. 地区识别用 name + host 字符串匹配, 不是 GeoIP. 主机名无地区线索的节点会归 `other` 桶
2. TCP 探活只能判断端口可达. TLS 握手 / 协议层校验未做 (P2 TODO)
3. 探活从发布机发起, 不等于最终用户网络. 实际 RTT 会略高
4. 公开免费源本身有大量死节点, 筛后可用节点数可能 < 20%. 长期应替换为自建节点源

## 后续 TODO

- 接 GeoIP 数据库 (MaxMind GeoLite2, 离线 mmdb)
- TLS handshake 探活 (区分端口活 vs 真可用)
- 协议级探活 (vmess/vless 各自 ping)
- 自建节点源支持 (本地 vps 列表)
- quality-history 趋势图 (按天聚合)