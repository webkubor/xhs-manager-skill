#!/usr/bin/env bash
# XHS 发布脚本
# 用法: ./publish.sh <draft_folder> [account]
# 例子: ./publish.sh drafts/2026-03-09-my-post sinanzhu

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DRAFT_FOLDER="$SCRIPT_DIR/$1"
ACCOUNT=${2:-sinanzhu}
PROFILE="$HOME/.xhs-manager/accounts/$ACCOUNT"
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
LOG="$SCRIPT_DIR/logs/publish.log"

mkdir -p "$SCRIPT_DIR/logs"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"; }

if [ ! -d "$DRAFT_FOLDER" ]; then
  log "❌ 草稿目录不存在: $DRAFT_FOLDER"; exit 1
fi

CONTENT_FILE="$DRAFT_FOLDER/content.md"
if [ ! -f "$CONTENT_FILE" ]; then
  log "❌ content.md 不存在: $CONTENT_FILE"; exit 1
fi

# 解析 content.md
TITLE=$(grep '^title:' "$CONTENT_FILE" | sed 's/title: *"//' | sed 's/"$//')
BODY=$(sed '1,/^---$/d;1,/^---$/d' "$CONTENT_FILE" | head -50)

log "🚀 开始发布 [$ACCOUNT]: $TITLE"

# 打开创作中心
agent-browser --profile "$PROFILE" --user-agent "$UA" open "https://creator.xiaohongshu.com/publish/publish"
sleep 4

# 检查是否已登录
SNAP=$(agent-browser snapshot 2>&1)
if echo "$SNAP" | grep -q "登录"; then
  log "⚠️  $ACCOUNT Cookie 已失效，请重新登录: ./login.sh $ACCOUNT"
  agent-browser close
  exit 1
fi

# 上传封面图（如有）
COVER=$(ls "$DRAFT_FOLDER"/*.{jpg,jpeg,png,webp} 2>/dev/null | head -1)
if [ -n "$COVER" ]; then
  log "📷 上传封面: $(basename $COVER)"
  # 找到上传按钮 ref
  UPLOAD_REF=$(agent-browser snapshot 2>&1 | grep -i "upload\|上传\|file" | grep "ref=" | head -1 | grep -o 'ref=e[0-9]*' | head -1 | sed 's/ref=//')
  if [ -n "$UPLOAD_REF" ]; then
    agent-browser upload "@$UPLOAD_REF" "$COVER"
    agent-browser wait 3000
  fi
fi

# 填写标题
TITLE_REF=$(agent-browser snapshot 2>&1 | grep -i "标题\|title" | grep "ref=" | head -1 | grep -o 'ref=e[0-9]*' | head -1 | sed 's/ref=//')
if [ -n "$TITLE_REF" ]; then
  agent-browser fill "@$TITLE_REF" "$TITLE"
  agent-browser wait 500
fi

# 填写正文
BODY_REF=$(agent-browser snapshot 2>&1 | grep -i "正文\|content\|描述" | grep "ref=" | head -1 | grep -o 'ref=e[0-9]*' | head -1 | sed 's/ref=//')
if [ -n "$BODY_REF" ]; then
  agent-browser fill "@$BODY_REF" "$BODY"
  agent-browser wait 500
fi

# 点击发布
agent-browser snapshot > /tmp/xhs_snap.txt 2>&1
PUB_REF=$(grep -i '发布' /tmp/xhs_snap.txt | grep "button\|ref=" | grep -o 'ref=e[0-9]*' | tail -1 | sed 's/ref=//')
if [ -n "$PUB_REF" ]; then
  agent-browser click "@$PUB_REF"
  agent-browser wait 5000
  log "✅ [$ACCOUNT] 发布成功: $TITLE"
else
  log "⚠️  找不到发布按钮，请手动检查"
fi

agent-browser close
