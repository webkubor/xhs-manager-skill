# 📝 Phase 2: 小红书自动发布协议 (Publishing Protocol)

> **前置条件**: 必须先完成 **[Phase 1: 账号登录](./login-sop.md)**，确保 Session 已持久化。
> 若 `~/.xhs-manager/accounts/<account_id>/Default/Cookies` 不存在，请先执行登录 SOP。

---

## 📋 内容模板 (Standard Template)

发布的素材放在 `drafts/` 目录下，格式如下：

```text
drafts/
└── 2026-03-04-cool-project/
    ├── content.md      # 包含标题、正文、标签
    ├── cover.png       # 封面图 (强制 3:4 或 1:1)
    └── assets/         # 更多配图
```

`content.md` 示例：

```markdown
---
title: "我发现了一个超酷的开源项目 🚀"
tags: ["#webkubor", "#小烛", "#AI工具", "#开发者", "#效率神器"]
---

正文内容，短句化，带 Emoji ✨

图片说明尽量有趣，3D Isometric 封面最佳。
```

---

## 🚀 自动发布流程 (Automation Flow)

### Step 1 — 复用已登录的 Session，从主站进入发布页

> ⚠️ **不要直接打开 creator.xiaohongshu.com**，该子域名 Cookie 需从主站跳转同步，否则会跳回登录页。

```bash
# 先打开主站（复用 session）
agent-browser \
  --profile ~/.xhs-manager/accounts/<account_id> \
  --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36" \
  open "https://www.xiaohongshu.com"

sleep 3
agent-browser snapshot   # 找到「创作中心」按钮 ref，例如 @e3
agent-browser click @e3  # 点击，展开子菜单
agent-browser snapshot   # 找到「创作服务」ref
agent-browser click @eN  # 点击进入发布页
```

---

### Step 2 — 获取页面元素快照

```bash
agent-browser snapshot -i
```

> 记录上传区、标题框、正文框、发布按钮的 `@ref` 编号。

---

### Step 3 — 上传封面与配图

```bash
# 上传封面（@eX 替换为实际 ref）
agent-browser upload @eX "drafts/<folder>/cover.png"
agent-browser wait 3000

# 若有多图继续上传
agent-browser upload @eX "drafts/<folder>/assets/img1.png"
agent-browser wait 2000
```

---

### Step 4 — 填写标题

```bash
agent-browser fill @eY "<标题内容>"
agent-browser wait 500
```

---

### Step 5 — 填写正文与标签

```bash
agent-browser fill @eZ "<正文内容> #webkubor #小烛 #标签3"
agent-browser wait 500
```

---

### Step 6 — 点击发布

```bash
agent-browser click @eN
agent-browser wait 5000
agent-browser snapshot -i
```

> 确认页面跳转到笔记详情页即发布成功 ✅

---

## 🎨 审美约束 (Aesthetic Constraints)

| 项目 | 要求 |
| --- | --- |
| 标签数 | 5–10 个，必须含 `#webkubor` `#小烛` |
| 封面图比例 | 3:4（推荐）或 1:1 |
| 封面风格 | 3D Isometric 优先 |
| 文案风格 | 短句化 + Emoji，避免大段文字 |

---

## 🔄 矩阵分发（多账号）

对每个账号重复 Phase 2 流程，替换 `<account_id>` 即可：

```bash
# 账号1
agent-browser --profile ~/.xhs-manager/accounts/sinanzhu ... open ...

# 账号2
agent-browser close
agent-browser --profile ~/.xhs-manager/accounts/xiaozhu_ai ... open ...
```

---

> 如 Session 失效请返回 **[Phase 1: 登录 SOP](./login-sop.md)** 重新登录
