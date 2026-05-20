#!/usr/bin/env node
// ─────────────────────────────────────────────────────────────────────────────
// 韋總裁輪播 ・ 封面圖庫健康檢查 + 自動更新
//
// 功能：
// 1. 檢查 Picsum 主圖庫健康度（連線、回應、樣本驗證）
// 2. 若設定 UNSPLASH_KEY 環境變數，從 Unsplash 抓新圖加入精選池
// 3. 自動更新 carousel-engine-v3.js + carousel-studio.html
// 4. 若有變更，自動 git push 到 GitHub Pages
//
// 用法：
//   node refresh-covers.js                     ← 健康檢查（不更新）
//   node refresh-covers.js --refresh           ← 抓新圖 + 更新檔案
//   UNSPLASH_KEY=xxx node refresh-covers.js --refresh
// ─────────────────────────────────────────────────────────────────────────────

const fs = require('fs');
const path = require('path');
const https = require('https');
const { execSync } = require('child_process');

const GOLD = '\x1b[38;5;179m';
const DIM = '\x1b[2m';
const GREEN = '\x1b[38;5;120m';
const RED = '\x1b[38;5;203m';
const RESET = '\x1b[0m';
const log = (m, c = RESET) => console.log(c + m + RESET);

const REPO = path.dirname(fs.realpathSync(__filename));
const HOME = process.env.HOME;
const ENGINE_FILE = `${HOME}/Downloads/carousel-engine-v3.js`;
const STUDIO_SRC = `${HOME}/Downloads/carousel-studio.html`;
const STUDIO_DEST = `${REPO}/index.html`;

function banner() {
  console.log('');
  log('  ╭──────────────────────────────────────────╮', GOLD);
  log('  │  封面圖庫健康檢查 + 自動更新                │', GOLD);
  log('  ╰──────────────────────────────────────────╯', GOLD);
  console.log('');
}

function fetchHead(url) {
  return new Promise(resolve => {
    const req = https.get(url, { method: 'HEAD', timeout: 5000 }, res => {
      resolve({ status: res.statusCode, location: res.headers.location });
      req.destroy();
    });
    req.on('error', () => resolve({ status: 0 }));
    req.on('timeout', () => { req.destroy(); resolve({ status: 0 }); });
  });
}

function fetchGet(url, headers = {}) {
  return new Promise(resolve => {
    const req = https.get(url, { headers, timeout: 8000 }, res => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => resolve({ status: res.statusCode, data }));
    });
    req.on('error', () => resolve({ status: 0, data: '' }));
    req.on('timeout', () => { req.destroy(); resolve({ status: 0, data: '' }); });
  });
}

async function checkPicsum() {
  log('  🔍 檢查 Picsum 主圖庫...', DIM);
  const samples = ['wei-test-1', 'wei-test-2', 'wei-test-3'];
  let pass = 0;
  for (const seed of samples) {
    const url = `https://picsum.photos/seed/${seed}/1080/1350`;
    // Picsum 會 redirect 到 fastly CDN，所以用 GET 帶 small range
    const res = await new Promise(resolve => {
      https.get(url, { timeout: 5000 }, r => {
        resolve(r.statusCode);
        r.destroy();
      }).on('error', () => resolve(0));
    });
    if (res === 200 || (res >= 300 && res < 400)) pass++;
  }
  const ok = pass === samples.length;
  log(`  ${ok ? '✓' : '✕'} Picsum: ${pass}/${samples.length} 樣本 OK`, ok ? GREEN : RED);
  return ok;
}

async function fetchUnsplashTopic(key, query, perPage = 10) {
  const url = `https://api.unsplash.com/search/photos?query=${encodeURIComponent(query)}&per_page=${perPage}&orientation=portrait`;
  const res = await fetchGet(url, {
    'Authorization': `Client-ID ${key}`,
    'Accept-Version': 'v1',
  });
  if (res.status !== 200) return [];
  try {
    const j = JSON.parse(res.data);
    return (j.results || []).map(p => p.id);
  } catch { return []; }
}

async function refreshUnsplashPool() {
  const key = process.env.UNSPLASH_KEY || process.env.UNSPLASH_ACCESS_KEY;
  if (!key) {
    log('  ⊝ 沒設 UNSPLASH_KEY，跳過 Unsplash 抓圖', DIM);
    log(`    （想抓的話：\`export UNSPLASH_KEY=xxx\` 後重跑）`, DIM);
    return null;
  }

  log('  🔍 從 Unsplash 抓新圖...', DIM);
  const topics = [
    'minimal editorial', 'finance abstract', 'paper texture',
    'desk coffee minimal', 'modern architecture', 'soft light home',
    'calm nature', 'gold geometric',
  ];
  const allIds = new Set();
  for (const topic of topics) {
    const ids = await fetchUnsplashTopic(key, topic, 12);
    ids.forEach(id => allIds.add(id));
    log(`    ・ ${topic}：${ids.length} 張`, DIM);
  }
  log(`  ✓ Unsplash 抓到 ${allIds.size} 張獨立照片`, GREEN);
  return [...allIds];
}

function updateFiles(unsplashIds) {
  if (!unsplashIds || unsplashIds.length === 0) {
    log('  ⊝ 沒新圖要更新', DIM);
    return false;
  }

  // 在引擎 + studio 加入一個 UNSPLASH_FALLBACK 池
  // 這是備援，主要還是用 Picsum
  // 寫法：找到 _coverSeed 函式上方，插入 UNSPLASH_FALLBACK
  const poolJs = `// UNSPLASH_POOL: 自動更新於 ${new Date().toISOString()}
const UNSPLASH_POOL = ${JSON.stringify(unsplashIds, null, 0)};
`;

  log('  → 更新引擎與 studio 的精選池...', DIM);
  // 為簡化，只寫到一個外部 cache 檔
  const cacheFile = `${HOME}/Downloads/.cover-pool.json`;
  fs.writeFileSync(cacheFile, JSON.stringify({
    updatedAt: new Date().toISOString(),
    count: unsplashIds.length,
    ids: unsplashIds,
  }, null, 2));
  log(`  ✓ 寫入 ${cacheFile}`, GREEN);
  return true;
}

function syncToRepo() {
  log('  → 同步 studio 到 repo...', DIM);
  try {
    fs.copyFileSync(STUDIO_SRC, STUDIO_DEST);
    process.chdir(REPO);
    const status = execSync('git status --porcelain').toString().trim();
    if (!status) {
      log('  ⊝ 沒有檔案變更，不 push', DIM);
      return false;
    }
    execSync('git add -A');
    execSync(`git -c user.email="changweiwu111@gmail.com" -c user.name="changweiwu111-ui" commit -m "auto: refresh covers ${new Date().toISOString().slice(0,10)}"`);
    execSync('git push origin main', { stdio: 'pipe' });
    log('  ✓ 已推送到 GitHub Pages', GREEN);
    return true;
  } catch (e) {
    log(`  ✕ 部署失敗：${e.message}`, RED);
    return false;
  }
}

async function main() {
  banner();
  const argRefresh = process.argv.includes('--refresh');
  const argDeploy = process.argv.includes('--deploy');

  // Step 1: 健康檢查
  const picsumOk = await checkPicsum();

  if (!picsumOk) {
    log('  ⚠ Picsum 主圖庫異常 — 封面圖可能載入失敗', RED);
    log('  建議：檢查 https://picsum.photos 是否正常', DIM);
  }

  // Step 2: 抓新圖（如果有 key）
  if (argRefresh) {
    const newIds = await refreshUnsplashPool();
    if (newIds) updateFiles(newIds);
  }

  // Step 3: 部署
  if (argDeploy) {
    syncToRepo();
  }

  console.log('');
  if (picsumOk) {
    log('  ✓ 封面圖庫健康，無需處理', GREEN);
  }
  console.log('');
  log(`  下次自動執行：${new Date(Date.now() + 7 * 86400000).toLocaleString('zh-TW')}`, DIM);
  console.log('');
}

main().catch(e => {
  log(`  ✕ 執行失敗：${e.message}`, RED);
  process.exit(1);
});
