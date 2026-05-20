#!/bin/bash
# Mac 雙擊執行
cd "$(dirname "${BASH_SOURCE[0]}")"
./deploy.sh
echo ""
echo "按任意鍵關閉..."
read -n 1
