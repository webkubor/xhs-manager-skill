# 📢 XHS Manager Skill

> **定位**: 小红书多账号运营中枢。`agent-browser` 负责可视化操作（改资料/截图），`xiaohongshu-mcp` 负责高频自动化（点赞/评论/发布）。两者配合，token 消耗降低 **50-100 倍**。

**当前版本**: `v3.0.0`

---

## 📦 安装（两步搞定）

### Step 1 — 安装 agent-browser（多账号可视化）

```bash
npm install -g agent-browser && agent-browser install
```

### Step 2 — 安装 xiaohongshu-mcp（高频自动化，核心）

```bash
# 下载对应平台的二进制（macOS Apple Silicon）
mkdir -p ~/.xhs-manager/mcp

# 获取最新版本并下载
LATEST=$(curl -s https://api.github.com/repos/xpzouying/xiaohongshu-mcp/releases/latest | python3 -c "import json,sys; print(json.load(sys.stdin)['tag_name'])")
curl -L -o /tmp/xhs-mcp.tar.gz \
  "https://github.com/xpzouying/xiaohongshu-mcp/releases/download/${LATEST}/xiaohongshu-mcp-darwin-arm64.tar.gz"
tar -xzf /tmp/xhs-mcp.tar.gz -C ~/.xhs-manager/mcp/
chmod +x ~/.xhs-manager/mcp/xiaohongshu-mcp-darwin-arm64
chmod +x ~/.xhs-manager/mcp/xiaohongshu-login-darwin-arm64
```

> **其他平台**: [GitHub Releases](https://github.com/xpzouying/xiaohongshu-mcp/releases) 选择对应版本

---

## 🔐 登录账号

**每个账号需要独立目录**，实现物理隔离：

```bash
# 账号1 - 例：sinanzhu
mkdir -p ~/.xhs-manager/accounts/sinanzhu
cp ~/.xhs-manager/mcp/xiaohongshu-mcp-darwin-arm64 ~/.xhs-manager/accounts/sinanzhu/
cp ~/.xhs-manager/mcp/xiaohongshu-login-darwin-arm64 ~/.xhs-manager/accounts/sinanzhu/

# 登录（会弹出浏览器扫码）
cd ~/.xhs-manager/accounts/sinanzhu && ./xiaohongshu-login-darwin-arm64

# 账号2 - 例：xiaozhu_xiake
mkdir -p ~/.xhs-manager/accounts/xiaozhu_xiake
cp ~/.xhs-manager/mcp/xiaohongshu-mcp-darwin-arm64 ~/.xhs-manager/accounts/xiaozhu_xiake/
cp ~/.xhs-manager/mcp/xiaohongshu-login-darwin-arm64 ~/.xhs-manager/accounts/xiaozhu_xiake/

cd ~/.xhs-manager/accounts/xiaozhu_xiake && ./xiaohongshu-login-darwin-arm64
```

> ⚠️ 登录工具会弹出浏览器，扫码后 `INFO: 当前登录状态: true` 即成功

---

## 🚀 启动 MCP 服务

每个账号分配独立端口：

```bash
# 账号1（18061端口）
cd ~/.xhs-manager/accounts/sinanzhu && \
  ./xiaohongshu-mcp-darwin-arm64 -port :18061 > /tmp/xhs-sinanzhu.log 2>&1 &

# 账号2（18062端口）
cd ~/.xhs-manager/accounts/xiaozhu_xiake && \
  ./xiaohongshu-mcp-darwin-arm64 -port :18062 > /tmp/xhs-xiaozhu.log 2>&1 &
```

注册到 mcporter（需提前安装 `npm install -g mcporter`）：

```bash
mcporter config add xhs-sinanzhu http://localhost:18061/mcp
mcporter config add xhs-xiaozhu http://localhost:18062/mcp

# 验证
mcporter list | grep xhs
# 期望看到：
# - xhs-sinanzhu (13 tools, 0.1s)
# - xhs-xiaozhu (13 tools, 0.1s)
```

---

## 🤖 AI 操作说明

安装完成后，AI 可直接调用：

```bash
# 点赞
mcporter call xhs-sinanzhu.like_feed feed_id="xxx" xsec_token="xxx"

# 评论
mcporter call xhs-sinanzhu.post_comment_to_feed feed_id="xxx" xsec_token="xxx" content="好看"

# 搜索内容
mcporter call xhs-sinanzhu.search_feeds keyword="古风武侠"

# 发布图文
mcporter call xhs-sinanzhu.publish_content title="标题" content="正文" images='["图片路径"]'

# 检查登录状态
mcporter call xhs-sinanzhu.check_login_status
```

---

## 📊 两种工具的分工

| 场景 | 工具 | 原因 |
|------|------|------|
| 每日点赞/评论养号 | xiaohongshu-mcp | token 消耗极低 |
| 发布图文/视频 | xiaohongshu-mcp | 直接 API 调用 |
| 修改昵称/头像/简介 | agent-browser | MCP 暂不支持 |
| 账号数据查看 | agent-browser | 截图可视化 |
| MCP 异常时备用 | agent-browser | 兜底方案 |

---

## ⚠️ 注意事项

| 问题 | 说明 |
|------|------|
| 同账号多端登录 | 小红书会踢出其他端，每账号只启动一个 MCP 实例 |
| xsec_token 时效 | 搜索拿到 token 后立即使用，不要缓存超过 1 分钟 |
| 操作频率 | 点赞/评论间隔至少 2 秒，每日互动上限约 100 次 |
| 重启后 | 需重新启动 MCP 进程（可配置开机自启） |

---

## 📝 Changelog

### [v3.0.0] - 2026-03-09
- **核心升级**: 集成 xiaohongshu-mcp，token 消耗降低 50-100 倍
- **多账号**: 每账号独立目录 + 独立端口，物理隔离
- **新增**: 养号脚本 `scripts/xhs_daily_nurture.py`（点赞+评论+自动重启）
- **新增**: 支持 cron 每日自动执行

### [v2.0.0] - 2026-03-09
- 修正 `--headed` 参数，agent-browser 登录可见弹窗

### [v1.0.0] - 2026-03-04
- 基于 agent-browser 的多账号隔离原型

---

MIT © [webkubor](https://github.com/webkubor)
