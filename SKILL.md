---
name: xhs-manager-skill
description: "XHS (Little Red Book) 双账号管理与定时发文。两账号各自隔离，AI 直接操作发布图文。"
version: 2.0.0
---

# 📢 XHS 双账号管理 (小红书矩阵发文)

## 账号配置

| 账号 ID | 说明 | Profile 路径 |
|--------|------|-------------|
| `sinanzhu` | 主账号 | `~/.xhs-manager/accounts/sinanzhu` |
| `xiaozhu_xiake` | 第二账号 | `~/.xhs-manager/accounts/xiaozhu_xiake` |

**关键工具**: `agent-browser`（已安装）
**草稿目录**: `~/Desktop/skills/xhs-manager-skill/drafts/`
**日志**: `~/Desktop/skills/xhs-manager-skill/logs/publish.log`

---

## 工作流

### 1. 检查登录状态

```bash
agent-browser --profile ~/.xhs-manager/accounts/sinanzhu \
  --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36" \
  open https://www.xiaohongshu.com
agent-browser snapshot
# 看到头像/个人主页 = 已登录 ✅；看到登录框 = 需重新登录
agent-browser close
```

### 2. 重新登录（Cookie 失效时）

```bash
bash ~/Desktop/skills/xhs-manager-skill/scripts/login.sh sinanzhu
bash ~/Desktop/skills/xhs-manager-skill/scripts/login.sh xiaozhu_xiake
```

### 3. 准备草稿

在 `drafts/` 下新建文件夹，结构：

```
drafts/
└── 2026-03-09-post-name/
    ├── content.md     # 标题 + 正文 + 标签
    ├── cover.jpg      # 封面图（3:4 比例最佳）
    └── img2.jpg       # 更多配图（可选）
```

`content.md` 格式：

```markdown
---
title: "文章标题 🚀"
account: "sinanzhu"       # sinanzhu 或 xiaozhu_xiake，不填则两个都发
tags: ["#标签1", "#标签2"]
---

正文内容，短句 + Emoji 风格

1️⃣ 第一点
2️⃣ 第二点
```

### 4. 发布

```bash
bash ~/Desktop/skills/xhs-manager-skill/scripts/publish.sh drafts/2026-03-09-post-name sinanzhu
```

---

## AI 直接操作发布流程（核心 SOP）

当王爷说"帮我发这篇文章"时，按此流程执行：

**Step 1** — 接收内容（标题、正文、图片路径）

**Step 2** — 创建草稿目录和 content.md

**Step 3** — 打开发布页（用 exec 运行 agent-browser）：

```bash
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
agent-browser --profile ~/.xhs-manager/accounts/<account_id> --user-agent "$UA" open "https://creator.xiaohongshu.com/publish/publish"
sleep 4
agent-browser snapshot
```

**Step 4** — 根据 snapshot 的 ref 填写标题、正文，上传图片，点击发布

**Step 5** — 确认发布成功，记录日志

---

## 定时任务

用 openclaw cron 每天定时触发，任务描述：

```
检查 ~/Desktop/skills/xhs-manager-skill/drafts/ 目录，
找今天日期开头的文件夹（YYYY-MM-DD-*），
按 content.md 里的 account 字段，用 agent-browser 发布到对应小红书账号。
发布完毕后在日志里记录结果。
```

---

## 参考文档

- [多账号隔离说明](references/multi-account-isolation.md)
- [登录 SOP](references/login-sop.md)
- [发布 SOP](references/publish-sop.md)
- [防爬策略](references/agent-browser-sop.md)
