#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# 韋總裁輪播生成器 ・ 一鍵部署
# 把 ~/Downloads/carousel-studio.html 同步到 GitHub Pages
# 用法：./deploy.sh
# ─────────────────────────────────────────────────────────────────────────────

set -e

# 顏色
GOLD='\033[38;5;179m'
DIM='\033[2m'
GREEN='\033[38;5;120m'
RED='\033[38;5;203m'
RESET='\033[0m'

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="$HOME/Documents/_韋總裁工作區/05_IG內容創作/輪播HTML/carousel-studio.html"
TARGET_FILE="$REPO_DIR/index.html"
LIVE_URL="https://changweiwu111-ui.github.io/wei-carousel-studio/"

echo ""
echo -e "${GOLD}  ╭────────────────────────────────────────╮${RESET}"
echo -e "${GOLD}  │  韋總裁輪播生成器 ・ 一鍵部署              │${RESET}"
echo -e "${GOLD}  ╰────────────────────────────────────────╯${RESET}"
echo ""

# 1. 檢查源檔
if [ ! -f "$SOURCE_FILE" ]; then
  echo -e "${RED}  ✕ 找不到 $SOURCE_FILE${RESET}"
  echo -e "${DIM}    請確認 carousel-studio.html 在 Downloads 資料夾${RESET}"
  exit 1
fi

# 2. 複製
echo -e "${DIM}  → 複製最新版 carousel-studio.html...${RESET}"
cp "$SOURCE_FILE" "$TARGET_FILE"

cd "$REPO_DIR"

# 3. 檢查有沒有變更
if git diff --quiet && git diff --staged --quiet; then
  echo -e "${DIM}  → 沒有變更，不需部署${RESET}"
  echo ""
  echo -e "${GOLD}  目前線上版：${RESET}${LIVE_URL}"
  echo ""
  exit 0
fi

# 4. Commit + Push
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
COMMIT_MSG="${1:-update studio · $TIMESTAMP}"

echo -e "${DIM}  → 提交：$COMMIT_MSG${RESET}"
git add -A
git commit -m "$COMMIT_MSG" > /dev/null

echo -e "${DIM}  → 推送到 GitHub...${RESET}"
git push origin main > /dev/null 2>&1

echo ""
echo -e "${GREEN}  ✓ 部署完成${RESET}"
echo ""
echo -e "${GOLD}  網址：${RESET}${LIVE_URL}"
echo -e "${DIM}  GitHub 會在 1-3 分鐘內更新${RESET}"
echo ""

# 5. 自動開啟
read -t 5 -p "$(echo -e ${DIM}  5 秒後自動開啟瀏覽器，按 Enter 立即開啟，Ctrl+C 取消${RESET})" || true
open "$LIVE_URL"
echo ""
