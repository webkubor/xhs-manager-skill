/**
 * XHS 截图脚本 - 用法: node scripts/screenshot.js <account_id>
 * 复用已保存的 Session，截取个人主页
 */
import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';
import os from 'os';

const accountId = process.argv[2];
if (!accountId) {
  console.error('用法: node scripts/screenshot.js <account_id>');
  process.exit(1);
}

const sessionDir = path.join(os.homedir(), '.xhs-manager', 'sessions');
const sessionFile = path.join(sessionDir, `${accountId}.json`);
const screenshotFile = path.join(sessionDir, `${accountId}_profile.png`);

if (!fs.existsSync(sessionFile)) {
  console.error(`❌ 未找到 Session，请先运行: node scripts/login.js ${accountId}`);
  process.exit(1);
}

async function main() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
    storageState: sessionFile,
    viewport: { width: 1280, height: 800 },
  });

  const page = await context.newPage();
  await page.addInitScript(() => {
    Object.defineProperty(navigator, 'webdriver', { get: () => undefined });
  });

  console.log(`📸 正在截取 [${accountId}] 个人主页...`);
  await page.goto('https://www.xiaohongshu.com/user/profile/me', { waitUntil: 'domcontentloaded', timeout: 20000 });
  await page.waitForTimeout(3000);
  await page.screenshot({ path: screenshotFile });
  console.log(`✅ 截图已保存: ${screenshotFile}`);

  await browser.close();
}

main().catch(console.error);
