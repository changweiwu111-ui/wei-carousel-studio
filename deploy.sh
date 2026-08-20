#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# 韋總裁輪播生成器 ・ 一鍵部署（雙站）
# 母檔（工作區 carousel-studio.html）→ repo → GitHub Pages ＋ CF Pages 同步上線
# 用法：./deploy.sh ["commit 訊息"]
# ─────────────────────────────────────────────────────────────────────────────

set -e

# 顏色
GOLD='\033[38;5;179m'
DIM='\033[2m'
GREEN='\033[38;5;120m'
RED='\033[38;5;203m'
RESET='\033[0m'

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="$HOME/Documents/_韋總裁工作區/05_IG內容創作/carousel 引擎與工具/carousel-studio.html"
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
  echo -e "${DIM}    請確認 carousel-studio.html 在工作區「carousel 引擎與工具」資料夾${RESET}"
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
echo -e "${GREEN}  ✓ GitHub Pages 部署完成${RESET}"

# 5. 同步部署 CF Pages（weizongcai-carousel，正式站）
#    非互動環境用 refresh_token 換 access_token（見記憶 feedback_wrangler_deploy_auth）
echo -e "${DIM}  → 同步部署 Cloudflare Pages（weizongcai-carousel）...${RESET}"
CF_OK=0
CFG="$HOME/.wrangler/config/default.toml"
[ ! -f "$CFG" ] && CFG="$HOME/Library/Preferences/.wrangler/config/default.toml"
if [ -f "$CFG" ]; then
  RT=$(grep '^refresh_token' "$CFG" | sed -E 's/.*= *"([^"]*)".*/\1/')
  RESP=$(curl -s -X POST "https://dash.cloudflare.com/oauth2/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "grant_type=refresh_token" \
    --data-urlencode "refresh_token=$RT" \
    --data-urlencode "client_id=54d11594-84e4-41aa-b438-e81b8fa78ee7")
  AT=$(echo "$RESP" | python3 -c "import sys,json;print(json.load(sys.stdin).get('access_token',''))" 2>/dev/null)
  NRT=$(echo "$RESP" | python3 -c "import sys,json;print(json.load(sys.stdin).get('refresh_token',''))" 2>/dev/null)
  if [ -n "$AT" ]; then
    # refresh_token 單次使用會輪替，新的要寫回 config
    if [ -n "$NRT" ]; then
      python3 - "$CFG" "$NRT" <<'PYEOF'
import re,sys
p,nrt=sys.argv[1],sys.argv[2]
s=open(p).read()
open(p,'w').write(re.sub(r'^refresh_token *= *"[^"]*"', f'refresh_token = "{nrt}"', s, flags=re.M))
PYEOF
    fi
    CLOUDFLARE_API_TOKEN="$AT" CLOUDFLARE_ACCOUNT_ID=c3edd1697f3fc5654a89cd7383e0bd55 \
      npx wrangler pages deploy "$REPO_DIR" --project-name=weizongcai-carousel --branch=main --commit-dirty=true \
      > /dev/null 2>&1 && CF_OK=1
  fi
fi
if [ "$CF_OK" = "1" ]; then
  echo -e "${GREEN}  ✓ CF Pages 部署完成${RESET}"
else
  echo -e "${RED}  ✕ CF Pages 部署失敗（GH Pages 不受影響）——請叫 Claude 檢查 wrangler 授權${RESET}"
fi

echo ""
echo -e "${GOLD}  正式站：${RESET}https://weizongcai-carousel.pages.dev/"
echo -e "${GOLD}  GH 站　：${RESET}${LIVE_URL}${DIM}（1-3 分鐘內更新）${RESET}"
echo ""

# 6. 自動開啟（僅互動終端機）
if [ -t 0 ]; then
  read -t 5 -p "$(echo -e ${DIM}  5 秒後自動開啟瀏覽器，按 Enter 立即開啟，Ctrl+C 取消${RESET})" || true
  open "https://weizongcai-carousel.pages.dev/"
fi
echo ""
