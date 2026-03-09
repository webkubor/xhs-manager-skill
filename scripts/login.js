/**
 * XHS 登录脚本 - 使用真实 Chrome 驱动，绕过反爬检测
 * 用法: node scripts/login.js <account_id> <account_name>
 */
import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';
import os from 'os';

const accountId = process.argv[2];
const accountName = process.argv[3] || accountId;

if (!accountId) {
  console.error('用法: node scripts/login.js <account_id> <account_name>');
  process.exit(1);
}

const sessionDir = path.join(os.homedir(), '.xhs-manager', 'sessions');
const profileDir = path.join(os.homedir(), '.xhs-manager', 'profiles', accountId);
const screenshotFile = path.join(sessionDir, `${accountId}_profile.png`);

fs.mkdirSync(sessionDir, { recursive: true });
fs.mkdirSync(profileDir, { recursive: true });

async function main() {
  // 使用真实 Chrome + 持久化 Profile，完全模拟真人
  const context = await chromium.launchPersistentContext(profileDir, {
    executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    headless: false,
    args: ['--no-first-run', '--no-default-browser-check'],
    viewport: { width: 1280, height: 800 },
  });

  const page = await context.newPage();

  console.log(`\n🚀 打开小红书 [账号: ${accountName}]`);
  await page.goto('https://www.xiaohongshu.com', { waitUntil: 'domcontentloaded', timeout: 30000 });
  await page.waitForTimeout(3000);

  // 检查是否已登录（有登录框就需要扫码）
  const needLogin = await page.$('.login-container, [class*="loginContainer"], [class*="login-card"]').catch(() => null);

  if (!needLogin) {
    console.log('✅ 检测到已登录状态！');
  } else {
    console.log('📱 请在浏览器窗口中扫码登录...');
    console.log('⏳ 等待登录完成（最多 120 秒）...\n');

    await page.waitForURL(url => !url.includes('login'), { timeout: 120000 })
      .catch(() => console.log('⚠️  超时，尝试继续...'));

    await page.waitForTimeout(3000);
    console.log('✅ 登录完成！');
  }

  // 截图个人主页
  console.log('📸 截取个人主页...');
  await page.goto('https://www.xiaohongshu.com/user/profile/me', { waitUntil: 'domcontentloaded', timeout: 20000 });
  await page.waitForTimeout(3000);
  await page.screenshot({ path: screenshotFile });
  console.log(`🖼️  截图: ${screenshotFile}`);

  await context.close();
  console.log(`💾 Profile 已保存: ${profileDir}`);
  console.log(`\n✅ 账号 [${accountName}] 配置完成！`);
}

main().catch(console.error);
