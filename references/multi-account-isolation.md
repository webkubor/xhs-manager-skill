# XHS 多账号隔离登录指南

## 🛡️ 核心原理
为了防止小红书平台识别关联账号，我们采用 **“物理环境隔离”** 策略。

### 1. 目录结构 (Directory Structure)
```text
accounts/
├── sinanzhu/          # 司南烛主账号 (Profile 1)
│   └── playwright/    # 独立浏览器数据
└── xiaozhu_ai/        # 小烛分账号 (Profile 2)
    └── playwright/    # 独立浏览器数据
```

### 2. 环境启动 (Launching)
使用 Playwright 启动时，强制指定 `userDataDir`:
```javascript
const context = await chromium.launchPersistentContext('./accounts/sinanzhu/playwright', {
  headless: false,
  viewport: { width: 375, height: 812 }
});
```

## ⚠️ 红线禁令
- **严禁**：在同一浏览器实例中切换账号登录。
- **建议**：每个账号绑定固定的代理 IP（如果可能）。
