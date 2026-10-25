#!/usr/bin/env bash
set -e

# ============================================================
# wish-star 一键部署脚本（本机维护用）
# 通过 GitHub REST API 上传文件，绕开本机 git push 的网络/TLS 限制
# 用法：bash deploy.sh
# ============================================================

REPO="yokim99/wish-star"
BRANCH="main"

# 基于脚本自身位置定位目录，保证在任意目录执行都可用
DIR="$(cd "$(dirname "$0")" && pwd)"

TOKEN=$(gh auth token)

FILES="index.html config.js records.json README.md"

if [ -z "$TOKEN" ]; then
  echo "❌ 未获取到 GitHub token，请先执行：gh auth login"
  exit 1
fi

echo "🚀 开始部署 $REPO（分支：$BRANCH）"
echo "   目录：$DIR"
echo ""

FAILED=0

for f in $FILES; do
  if [ ! -f "$DIR/$f" ]; then
    echo "❌ 文件不存在：$DIR/$f"
    FAILED=1
    continue
  fi

  echo "📄 处理 $f ..."

  # 1) 先 GET 取已有 sha（文件不存在时为空）
  SHA=$(curl -s "https://api.github.com/repos/$REPO/contents/$f?ref=$BRANCH" \
    -H "Authorization: Bearer $TOKEN" \
    -H "User-Agent: curl" | jq -r '.sha // empty')

  # 2) base64 编码（macOS 语法），去掉换行
  CONTENT=$(base64 -i "$DIR/$f" | tr -d '\n')

  # 3) 用 jq -n 构造 body：有 sha 则带 sha（更新），无 sha 则新建
  if [ -n "$SHA" ]; then
    BODY=$(jq -n \
      --arg message "chore: update $f" \
      --arg content "$CONTENT" \
      --arg sha "$SHA" \
      '{message: $message, content: $content, sha: $sha}')
    echo "   ↳ 已存在，执行更新（sha: ${SHA:0:8}...）"
  else
    BODY=$(jq -n \
      --arg message "chore: add $f" \
      --arg content "$CONTENT" \
      '{message: $message, content: $content}')
    echo "   ↳ 新建文件"
  fi

  # 4) PUT 上传，带 3 次重试（间隔 3 秒），200/201 视为成功
  OK=0
  for attempt in 1 2 3; do
    CODE=$(curl -s -X PUT "https://api.github.com/repos/$REPO/contents/$f" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Accept: application/vnd.github+json" \
      -H "User-Agent: curl" \
      --data-binary "$BODY" \
      -o /dev/null -w "%{http_code}")

    if [ "$CODE" = "200" ] || [ "$CODE" = "201" ]; then
      echo "   ✅ 成功（HTTP $CODE）"
      OK=1
      break
    fi

    echo "   ⚠️ 第 $attempt 次失败（HTTP $CODE），3 秒后重试..."
    sleep 3
  done

  if [ "$OK" -ne 1 ]; then
    echo "❌ $f 上传失败，已重试 3 次。"
    FAILED=1
  fi
done

if [ "$FAILED" -ne 0 ]; then
  echo ""
  echo "❌ 部署未全部成功，请检查网络或 gh 登录状态（gh auth login）。"
  exit 1
fi

echo ""
echo "✅ 部署完成！"
echo "主应用：https://raw.githack.com/yokim99/wish-star/main/index.html"
echo "维护说明：https://raw.githack.com/yokim99/wish-star/main/README.md"