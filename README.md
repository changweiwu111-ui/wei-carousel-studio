# 韋總裁輪播生成器

雜誌編輯誌風格的 IG 輪播生成器。**貼文案、自動寫好、匯出 PNG**，全程在瀏覽器內完成。

## 🌐 立即使用

**https://changweiwu111-ui.github.io/wei-carousel-studio/**

零安裝，貼網址打開就能用。

---

## 給夥伴的三步上手

### Step 1 ・ 開啟網址後填「個人品牌」
左側下方有「個人品牌」欄位，填你的名字 + IG handle。
每張輪播底下會自動掛你的署名。會存在你瀏覽器，下次自動帶入。

### Step 2 ・ 申請免費 Gemini API Key（推薦）

> 不申請也能用，但 AI 寫的品質會差很多。免費版本 1500 次/天，**不用信用卡**。

1. 去 https://aistudio.google.com/apikey （用 Google 帳號登入）
2. 點「Create API Key」→ 複製出來的 Key（`AIza...` 開頭）
3. 回到輪播生成器，點上方齒輪 ⚙
4. 貼到「Gemini API Key」欄位 → 按儲存

### Step 3 ・ 貼文案、生成、匯出

1. 在「**內容 ・ 貼什麼都可以**」框貼上：
   - 整段貼文文案
   - 一句話主題
   - 條列式重點
   - 任何 JSON（會自動偵測格式）

2. 按「**✦ 生成輪播**」(10-30 秒)

3. **預覽中點任何文字直接編輯**

4. 切換主題色（米暖 / 深藍 / 近黑 / 純白）

5. 按 **EXPORT PNG** 匯出，或 **EXPORT ALL** 一鍵出 7 張

---

## 三種 AI 服務（任選或自動切換）

| 服務 | 費用 | 適合 |
|---|---|---|
| **Gemini**（推薦）| ✅ 1500 次/天免費 | 每天發 1-2 篇的人 |
| **Anthropic Claude** | ❌ 每篇約 $0.01-0.03 USD | 想要最高品質 |
| **啟發式解析** | ✅ 完全免費，無 key | 沒申請任何 key 的時候 |

設定方式：點上方齒輪 ⚙，可以同時設多個 key，並選優先順序：
- **自動**（預設）：Gemini → Anthropic → 啟發式解析
- **只用 Gemini** / **只用 Anthropic** / **只用啟發式**

---

## 功能總覽

- **4 個主題色** ・ cream（米暖）/ ink（深藍）/ noir（近黑）/ paper（純白）
- **AI 自動生成** ・ Gemini 免費 + Anthropic 付費 + 啟發式解析三種選擇
- **即時編輯** ・ 預覽內任意文字點下去就能改
- **PNG 匯出** ・ 1080×1350，單張或一鍵 7 張
- **品牌個人化** ・ 姓名 + handle 換成自己的
- **封面圖自動換** ・ 依內容自動配 Picsum 圖庫圖
- **IG 附文自動同步** ・ 改完文字附文跟著更新
- **多種輸入格式** ・ 純文字、JSON、外部 `slides[]` 格式都吃

---

## 開發者文件（給韋總裁本人）

### 一鍵更新部署

```bash
# 改完 ~/Downloads/carousel-studio.html 之後雙擊：
~/Downloads/部署輪播生成器.command
```

### 封面圖自動更新

每週日凌晨 3 點 launchd 自動執行：
- `~/Library/LaunchAgents/com.wei.carousel-covers.plist`
- 腳本：`~/Downloads/wei-carousel-studio/refresh-covers.js`

手動執行健康檢查：
```bash
node ~/Downloads/wei-carousel-studio/refresh-covers.js
```

### Repo

`https://github.com/changweiwu111-ui/wei-carousel-studio`（public）

---

製作者：韋總裁｜吳昌韋・富邦人壽業務主任・IG @changw_0331
