# XHS 多账号隔离登录指南 v2.1

## 🛡️ 核心原理
为了防止小红书平台识别关联账号，我们采用 **“物理环境隔离”** 策略。在 v2.1 中，我们将账户数据存储路径从 Skill 目录迁移至用户全局家目录，以确保在更新 Skill 时数据不丢失。

### 1. 目录结构 (Directory Structure)
```text
~/.xhs-manager/         # 用户全局数据根目录
└── accounts/           # 矩阵账号存储库
    ├── sinanzhu/       # 司南烛主账号 (Profile 1)
    └── xiaozhu_ai/     # 小烛分账号 (Profile 2)
```

### 2. 环境启动 (Launching)
通过指定全局路径启动 `agent-browser`：

```bash
# 启动司南烛账号 (数据持久化在 ~/.xhs-manager/accounts/sinanzhu)
agent-browser --profile ~/.xhs-manager/accounts/sinanzhu --user-agent "..." open https://www.xiaohongshu.com

# 启动小烛 AI 账号
agent-browser --profile ~/.xhs-manager/accounts/xiaozhu_ai --user-agent "..." open https://www.xiaohongshu.com
```

## ⚠️ 开发者提示
- **数据主权**: 这种存储方式确保了用户在执行 `git pull` 或重新安装 Skill 时，其登录的 Session (Cookies/Tokens) 依然安全地保留在本地家目录中。
- **清理建议**: 用户若需彻底清除数据，可手动删除 `~/.xhs-manager` 目录。
