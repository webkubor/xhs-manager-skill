# 🤖 XHS Agent-Browser 自动化 SOP

> **本指南定义了如何使用 agent-browser 操控小红书，并内置了防爬绕过参数。**

## 🛡️ 环境伪装 (Bypass Anti-Crawling)

由于小红书对自动化工具检测严格，执行任何指令前**必须**注入以下伪装参数：

- **User-Agent**: `Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36`
- **建议指令**: `agent-browser --user-agent "..." open <url>`

## 🛠️ 核心操作集 (Core Commands)

### 1. 账号登录与隔离 (使用全局路径)

```bash
# 启动并保持特定账号的会话 (~/.xhs-manager 目录下)

 --profile ~/.xhs-manager/accounts/<account_id> --user-agent "..." open https://www.xiaohongshu.com
```

### 2. 搜索指定用户

```bash
# 搜索指令链
agent-browser fill @e2 "用户名" && agent-browser press Enter && agent-browser wait 5000 && agent-browser snapshot -i
```

### 3. 数据抓取

- 使用 `agent-browser snapshot -i` 获取带 @ref 的元素树。
- 定位粉丝数、笔记数等特定 @ref 进行数据提取。

## ⚠️ 注意事项

1. **Session 冲突**: 若要切换账号，必须先执行 `agent-browser close` 清理后台进程。
2. **延时策略**: 在 fill 与 click 之间建议加入 `agent-browser wait 1000` 模拟真人思考。
