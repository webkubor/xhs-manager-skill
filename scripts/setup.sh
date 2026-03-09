#!/usr/bin/env bash
# XHS Manager Skill 一键安装脚本
# 安装 agent-browser + xiaohongshu-mcp，引导多账号登录

set -e

echo ""
echo "🌸 XHS Manager Skill 安装向导"
echo "========================================"

# ======== Step 1: agent-browser ========
echo ""
echo "📦 Step 1: 安装 agent-browser..."

if command -v agent-browser &>/dev/null; then
  echo "  ✅ agent-browser 已安装，跳过"
else
  npm install -g agent-browser
  agent-browser install
  echo "  ✅ agent-browser 安装完成"
fi

# ======== Step 2: mcporter ========
echo ""
echo "📦 Step 2: 安装 mcporter..."

if command -v mcporter &>/dev/null; then
  echo "  ✅ mcporter 已安装，跳过"
else
  npm install -g mcporter
  echo "  ✅ mcporter 安装完成"
fi

# ======== Step 3: xiaohongshu-mcp ========
echo ""
echo "📦 Step 3: 下载 xiaohongshu-mcp 二进制..."

MCP_DIR="$HOME/.xhs-manager/mcp"
mkdir -p "$MCP_DIR"

# 检测平台
ARCH=$(uname -m)
OS=$(uname -s)

if [[ "$OS" == "Darwin" && "$ARCH" == "arm64" ]]; then
  ASSET="xiaohongshu-mcp-darwin-arm64.tar.gz"
elif [[ "$OS" == "Darwin" && "$ARCH" == "x86_64" ]]; then
  ASSET="xiaohongshu-mcp-darwin-amd64.tar.gz"
elif [[ "$OS" == "Linux" && "$ARCH" == "x86_64" ]]; then
  ASSET="xiaohongshu-mcp-linux-amd64.tar.gz"
elif [[ "$OS" == "Linux" && "$ARCH" == "arm64" ]]; then
  ASSET="xiaohongshu-mcp-linux-arm64.tar.gz"
else
  echo "  ⚠️  不支持的平台: $OS $ARCH"
  echo "  请手动从 https://github.com/xpzouying/xiaohongshu-mcp/releases 下载"
  exit 1
fi

# 获取最新版本
LATEST=$(curl -s https://api.github.com/repos/xpzouying/xiaohongshu-mcp/releases/latest \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['tag_name'])" 2>/dev/null)

if [[ -z "$LATEST" ]]; then
  echo "  ⚠️  获取最新版本失败，请检查网络"
  exit 1
fi

echo "  最新版本: $LATEST"

# 下载并解压
curl -L -o /tmp/xhs-mcp.tar.gz \
  "https://github.com/xpzouying/xiaohongshu-mcp/releases/download/${LATEST}/${ASSET}"
tar -xzf /tmp/xhs-mcp.tar.gz -C "$MCP_DIR/"
chmod +x "$MCP_DIR"/xiaohongshu-mcp-* "$MCP_DIR"/xiaohongshu-login-* 2>/dev/null || true
rm /tmp/xhs-mcp.tar.gz

echo "  ✅ xiaohongshu-mcp 安装到 $MCP_DIR"

# ======== Step 4: 账号配置 ========
echo ""
echo "🔑 Step 4: 配置账号"
echo ""
echo "你有几个小红书账号要管理？"
read -p "账号数量 (1-5): " ACCOUNT_COUNT

PORTS=(18061 18062 18063 18064 18065)
ACCOUNT_NAMES=()

for i in $(seq 1 $ACCOUNT_COUNT); do
  echo ""
  read -p "账号 $i 的别名（如：main_account）: " ACCOUNT_ID
  ACCOUNT_NAMES+=("$ACCOUNT_ID")
  PORT=${PORTS[$((i-1))]}
  ACCOUNT_DIR="$HOME/.xhs-manager/accounts/$ACCOUNT_ID"

  mkdir -p "$ACCOUNT_DIR"
  cp "$MCP_DIR"/xiaohongshu-mcp-* "$ACCOUNT_DIR/"
  cp "$MCP_DIR"/xiaohongshu-login-* "$ACCOUNT_DIR/"

  echo ""
  echo "  ▶ 正在登录账号 $i ($ACCOUNT_ID)..."
  echo "  浏览器即将弹出，请用手机小红书 App 扫码登录"
  echo "  登录成功后终端会显示: INFO: 当前登录状态: true"
  echo ""
  read -p "  按 Enter 开始登录..."

  cd "$ACCOUNT_DIR" && ./xiaohongshu-login-darwin-arm64 2>&1 || true
  cd - > /dev/null

  # 启动 MCP
  cd "$ACCOUNT_DIR" && \
    ./xiaohongshu-mcp-darwin-arm64 -port :$PORT > /tmp/xhs-${ACCOUNT_ID}.log 2>&1 &
  sleep 3

  # 注册到 mcporter
  mcporter config add "xhs-${ACCOUNT_ID}" "http://localhost:$PORT/mcp" 2>/dev/null || true

  echo "  ✅ 账号 $ACCOUNT_ID 配置完成（端口 $PORT）"
done

# ======== 验证 ========
echo ""
echo "🔍 验证安装..."
sleep 2
mcporter list 2>/dev/null | grep xhs || echo "  ⚠️  mcporter 未检测到 xhs 服务，请手动检查"

echo ""
echo "========================================"
echo "✅ 安装完成！"
echo ""
echo "已配置账号："
for name in "${ACCOUNT_NAMES[@]}"; do
  echo "  - xhs-${name}"
done
echo ""
echo "日常使用："
echo "  # 养号脚本（每日自动执行）"
echo "  python3 scripts/xhs_daily_nurture.py"
echo ""
echo "  # 手动操作"
echo "  mcporter call xhs-${ACCOUNT_NAMES[0]}.check_login_status"
echo "========================================"
