# 🔐 Phase 1: XHS 账号登录 & Session 持久化 SOP

> **目标**: 完成账号扫码登录，将 Session（Cookie/Token）持久化到本地，供后续发布流程复用。
> **只需执行一次**（或 Session 失效时重新执行）。

---

## 📋 前置条件

- 已安装 `agent-browser`（`npm install -g agent-browser && agent-browser install`）
- 准备好账号 ID（自定义，如 `sinanzhu`、`xiaozhu_ai`）

---

## 🚀 Step-by-Step 登录流程

### Step 1 — 创建账号 Profile 目录（首次）

```bash
mkdir -p ~/.xhs-manager/accounts/<account_id>
```

> 例：`mkdir -p ~/.xhs-manager/accounts/sinanzhu`

---

### Step 2 — 启动隔离浏览器并打开登录页

> ⚠️ **必须加 `--headed`**，否则浏览器在后台运行，没有扫码界面！

```bash
agent-browser --headed \
  --profile ~/.xhs-manager/accounts/<account_id> \
  --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36" \
  open "https://www.xiaohongshu.com"
```

---

### Step 3 — 等待页面加载，截取当前状态

```bash
agent-browser snapshot -i
```

> 查看是否出现**二维码**或已登录的首页，定位关键元素 `@ref`。

---

### Step 4a — 若出现二维码（扫码登录）

用手机小红书 App 扫码。扫描完成后执行：

```bash
agent-browser wait 8000
agent-browser snapshot -i
```

确认已跳转到首页（出现头像/主页按钮）即登录成功。

---

### Step 4b — 若出现账号密码输入框

```bash
# 填写手机号 / 用户名
agent-browser fill @eA "<手机号>"
agent-browser wait 500

# 填写密码
agent-browser fill @eB "<密码>"
agent-browser wait 500

# 点击登录按钮
agent-browser click @eC
agent-browser wait 5000
agent-browser snapshot -i
```

---

### Step 5 — 验证 Session 是否持久化

登录成功后，Session 自动保存在：

```text
~/.xhs-manager/accounts/<account_id>/
  ├── Default/
  │   └── Cookies        ← 核心 Cookie 文件
  └── Local State        ← 浏览器状态
```

**验证命令**：

```bash
ls ~/.xhs-manager/accounts/<account_id>/Default/
```

看到 `Cookies` 文件即表示 Session 已持久化 ✅

---

### Step 6 — 记录账号信息（可选，存入外部大脑）

```bash
# 在 accounts/ 下创建元信息文件，方便管理矩阵
cat > ~/.xhs-manager/accounts/<account_id>/meta.json << 'EOF'
{
  "account_id": "<account_id>",
  "display_name": "司南烛",
  "login_at": "2026-03-04",
  "status": "active",
  "notes": "主账号"
}
EOF
```

---

## ✅ 登录完成检查清单

- [ ] `~/.xhs-manager/accounts/<account_id>/Default/Cookies` 文件存在
- [ ] `agent-browser snapshot -i` 可见已登录的首页元素
- [ ] `meta.json` 已创建并记录账号信息

---

## ⚠️ 注意事项

| 情况 | 处理方式 |
| --- | --- |
| Session 失效（提示登录） | 重新执行本 SOP |
| 多账号切换 | 必须先 `agent-browser close`，再启动新 Profile |
| 切勿混用 Profile | 不同账号**必须**使用不同 `--profile` 路径 |

---

> ✅ 完成 Phase 1 后，进入 **[Phase 2: 自动发布协议](./publish-sop.md)**
