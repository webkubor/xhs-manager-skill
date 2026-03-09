# 📢 XHS Manager Skill (小红书矩阵管理大师)

> **定位**: 小红书多账号全自动运营中枢。基于 `agent-browser` 实现账号物理隔离、图文发布、矩阵分发。

**当前版本**: `v2.0.0`

---

## 📦 前置安装

```bash
# 安装 agent-browser（核心驱动，必须）
npm install -g agent-browser && agent-browser install
```

> ⚠️ `agent-browser install` 会下载内置 Chromium，首次约需 1 分钟。

---

## 🚀 快速上手

### Step 1 — 为每个账号创建隔离目录

```bash
# 替换 <account_id> 为你自己的账号别名，例如 main_account / side_account
mkdir -p ~/.xhs-manager/accounts/<account_id>
```

### Step 2 — 弹出浏览器，扫码登录

> ⚠️ **必须加 `--headed` 参数**，否则浏览器在后台运行，你看不到扫码界面。

```bash
agent-browser --headed \
  --profile ~/.xhs-manager/accounts/<account_id> \
  --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36" \
  open "https://www.xiaohongshu.com"
```

浏览器弹出后：
1. 用手机小红书 App 扫码，或输入手机号登录
2. 看到首页（左侧有「我」的头像）= 登录成功
3. 回来继续下一步

### Step 3 — 验证登录态 & 进入创作中心

**不要 close 浏览器**，直接运行：

```bash
# 检查是否已登录
agent-browser screenshot /tmp/xhs_check.png && open /tmp/xhs_check.png

# 点击创作中心菜单
agent-browser snapshot   # 找到「创作中心」的 ref 编号，例如 @e3
agent-browser click @e3  # 点击创作服务
```

登录态自动持久化在 `~/.xhs-manager/accounts/<account_id>/Default/Cookies`，**下次直接用，不用重新扫码**。

### Step 4 — 多账号：重复 Step 1-3

每个账号用不同的 `<account_id>` 目录，互不干扰：

```bash
mkdir -p ~/.xhs-manager/accounts/account_2

agent-browser close   # ⚠️ 必须先关闭当前 session

agent-browser --headed \
  --profile ~/.xhs-manager/accounts/account_2 \
  --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36" \
  open "https://www.xiaohongshu.com"
```

---

## 📝 发布图文笔记

### 准备内容草稿

在 `drafts/` 下新建文件夹：

```
drafts/
└── 2026-03-09-my-post/
    ├── content.md     # 标题 + 正文 + 标签
    └── cover.jpg      # 封面图（3:4 比例最佳）
```

`content.md` 格式：

```markdown
---
title: "文章标题 🚀"
account: "account_1"    # 指定发哪个账号的 account_id
tags: ["#标签1", "#标签2"]
---

正文内容，短句 + Emoji 风格 ✨

1️⃣ 第一点
2️⃣ 第二点
```

### 发布流程（AI 执行）

```bash
# 打开对应账号的创作中心
agent-browser --profile ~/.xhs-manager/accounts/<account_id> \
  --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36" \
  open "https://www.xiaohongshu.com"

agent-browser snapshot   # 找到创作中心 ref
agent-browser click @eN  # 点击「创作服务」进发布页
```

详细步骤见 [发布 SOP](./references/publish-sop.md)

---

## 🗂️ 目录结构

```
~/.xhs-manager/               # 所有账号数据（更新 skill 不丢失）
└── accounts/
    ├── account_1/            # 账号1 独立 Chromium Profile
    │   ├── Default/Cookies   # 登录 Cookie（自动持久化）
    │   └── meta.json         # 账号备注信息（可选）
    └── account_2/            # 账号2 完全隔离

xhs-manager-skill/            # 本 skill 目录
├── drafts/                   # 待发布内容草稿
├── scripts/                  # 辅助脚本
├── references/               # 详细 SOP 文档
└── SKILL.md                  # AI Agent 操作指南
```

---

## 🛡️ 核心设计原则

| 原则 | 说明 |
|------|------|
| **物理隔离** | 每账号独立 Chromium Profile，平台识别不到关联 |
| **数据安全** | 所有数据存 `~/.xhs-manager/`，更新 skill 不丢 session |
| **防爬伪装** | 内置真机级 User-Agent，模拟 macOS Chrome |
| **AI 原生** | 用 `agent-browser snapshot` 读页面结构，无需硬编码选择器 |

---

## ❓ 常见问题

**Q: 登录后下次还需要扫码吗？**
不需要。Cookie 自动保存在 Profile 目录，直接启动即已登录。

**Q: 切换账号时忘记 close 怎么办？**
```bash
agent-browser close   # 强制关闭当前 daemon，再启动新 profile
```

**Q: 怎么检查某个账号是否还在登录态？**
```bash
agent-browser --profile ~/.xhs-manager/accounts/<account_id> \
  --user-agent "..." open "https://www.xiaohongshu.com"
agent-browser screenshot /tmp/check.png && open /tmp/check.png
# 左侧有头像 = 已登录 ✅；有登录弹窗 = 需重新扫码
```

**Q: Cookie 失效了怎么办？**
重新走 Step 2，扫码登录一次即可。

---

## 📝 Changelog

### [v2.0.0] - 2026-03-09
- **重大修正**: 登录命令必须加 `--headed` 参数才能弹出浏览器扫码（原 README 缺失此参数）
- **重构**: SKILL.md 完整重写，覆盖 AI Agent 完整操作 SOP
- **新增**: `scripts/login.sh` 一键登录脚本
- **新增**: `drafts/.example/` 内容模板示例
- **优化**: 发布流程改为从主站点击创作中心跳转，避免 creator 子域名 Cookie 未同步问题
- **文档**: README 全面修订，所有命令经过实测验证

### [v1.3.0] - 2026-03-04
- 引入两阶段工作流（Phase 1 登录 + Phase 2 发布）
- 新增 login-sop.md

### [v1.0.0] - 2026-03-03
- 基于 Playwright 的多账号物理隔离原型

---

## 📚 详细文档

- [SKILL.md](./SKILL.md) — AI Agent 完整操作手册
- [登录 SOP](./references/login-sop.md)
- [发布 SOP](./references/publish-sop.md)
- [防爬策略](./references/agent-browser-sop.md)
- [多账号隔离](./references/multi-account-isolation.md)

---

MIT © [webkubor](https://github.com/webkubor)
