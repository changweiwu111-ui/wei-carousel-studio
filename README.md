# 韋總裁輪播生成器 ・ STUDIO

雜誌編輯誌風格 IG 輪播生成器。單檔 HTML，瀏覽器開啟即用。

## 🌐 線上版

**https://changweiwu111-ui.github.io/wei-carousel-studio/**

零安裝，貼網址給任何人都能用。

## ⚡ 一鍵部署（給韋總裁本人）

改完本機的 `carousel-studio.html` 之後，三種方式更新線上版：

### 最快：雙擊
```
~/Downloads/部署輪播生成器.command
```
（Mac 雙擊即跑，自動同步並開瀏覽器）

### Repo 內：
```
~/Downloads/wei-carousel-studio/部署.command
```

### 終端機：
```bash
cd ~/Downloads/wei-carousel-studio && ./deploy.sh
# 或附訊息：./deploy.sh "加新主題色 sand"
```

腳本會自動：
1. 把 `~/Downloads/carousel-studio.html` 複製成 repo 的 `index.html`
2. 偵測有變更才 commit + push
3. 開瀏覽器看更新後的線上版

## 功能

- **AI 生成** — 一句話主題 → 完整 7 張輪播（需 Anthropic API Key）
- **4 主題色** — 米暖 cream / 深藍 ink / 近黑 noir / 純白 paper
- **即時編輯** — 點預覽中任意文字直接改
- **PNG 匯出** — 單張或一鍵全部匯出（1080×1350）
- **品牌個人化** — 姓名 + handle 可換成自己的

## 使用流程

1. 在左側貼上 JSON 內容（或載入範例）
2. 選主題色 + 填關鍵字 + 工具名稱
3. 設定自己的姓名 / handle
4. 按「生成輪播」→ 右側預覽
5. 點預覽文字直接編輯
6. 按 EXPORT PNG 匯出

## AI 生成（選用）

1. 取得 Anthropic API Key：https://console.anthropic.com
2. Studio 點齒輪 ⚙ → 貼 Key → 儲存
3. 上方「AI 生成」框打主題或文案
4. 按「✦ 讓 AI 寫完整內容」
5. 15–30 秒後自動填入並預覽

Key 只存你瀏覽器的 localStorage，不會傳到任何伺服器。費用大約一張輪播 0.01–0.03 美金。

## 規格

- 七張結構：VIRAL（Hook / Pain / Pivot / Method / Authority / Proof / CTA）
- 字體：Noto Serif TC + Inter + JetBrains Mono
- 風格：Monocle / Kinfolk 雜誌編輯誌
- 輸出尺寸：1080 × 1350 px（IG 直式）

## 製作者

韋總裁｜吳昌韋・富邦人壽業務主任・IG @changw_0331
