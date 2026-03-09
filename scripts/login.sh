#!/usr/bin/env bash
# XHS 账号登录脚本
# 用法: ./login.sh sinanzhu
#       ./login.sh xiaozhu_xiake

ACCOUNT=${1:-sinanzhu}
PROFILE="$HOME/.xhs-manager/accounts/$ACCOUNT"
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"

mkdir -p "$PROFILE"

echo "🌸 正在打开 $ACCOUNT 的浏览器..."
echo "📋 请在浏览器中完成登录（扫码 or 手机号）"
echo "⏳ 登录成功后回来按 Enter..."

agent-browser --profile "$PROFILE" --user-agent "$UA" open "https://www.xiaohongshu.com"

read -p "✅ 按 Enter 确认已登录..."

agent-browser snapshot > /dev/null 2>&1
echo "💾 Session 已保存到: $PROFILE"
agent-browser close
echo "🎉 $ACCOUNT 登录完成！"
