const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer');

const BASE_URL = 'http://localhost:8080';

const PHONE_DIR = path.join(__dirname, '../store_assets/phone');
const TABLET_7_DIR = path.join(__dirname, '../store_assets/tablet_7inch');
const TABLET_10_DIR = path.join(__dirname, '../store_assets/tablet_10inch');

[PHONE_DIR, TABLET_7_DIR, TABLET_10_DIR].forEach(dir => {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
});

async function captureDeviceScreenshots(browser, width, height, outputDir, prefix) {
  console.log(`\n📸 Capturing screenshots for ${prefix} (${width}x${height})...`);
  const page = await browser.newPage();
  await page.setViewport({ width, height, deviceScaleFactor: 1 });

  // 1. Home Dashboard
  await page.goto(BASE_URL, { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 2500)); // Allow Flutter rendering & splash transition
  await page.screenshot({ path: path.join(outputDir, `${prefix}_01_home_dashboard.png`), type: 'png' });
  console.log(`  ✓ ${prefix}_01_home_dashboard.png`);

  // 2. Click Currency Tab (Index 1)
  try {
    const navButtons = await page.$$('div[role="button"], button, flt-semantics');
    // Try navigating to Currency or scrolling
    await page.evaluate(() => {
      window.scrollBy(0, 300);
    });
    await new Promise(r => setTimeout(r, 800));
    await page.screenshot({ path: path.join(outputDir, `${prefix}_02_home_scrolled.png`), type: 'png' });
    console.log(`  ✓ ${prefix}_02_home_scrolled.png`);
  } catch (e) {
    console.log(`  ! Error during scroll: ${e.message}`);
  }

  await page.close();
}

(async () => {
  try {
    const browser = await puppeteer.launch({
      headless: 'new',
      args: ['--no-sandbox', '--disable-setuid-sandbox', '--force-device-scale-factor=1']
    });

    // 1. Phone: 1080 x 1920 px (9:16 aspect ratio)
    await captureDeviceScreenshots(browser, 1080, 1920, PHONE_DIR, 'phone');

    // 2. 7-inch Tablet: 1200 x 1920 px (9:16 aspect ratio)
    await captureDeviceScreenshots(browser, 1200, 1920, TABLET_7_DIR, 'tablet_7in');

    // 3. 10-inch Tablet: 1600 x 2560 px (9:16 aspect ratio)
    await captureDeviceScreenshots(browser, 1600, 2560, TABLET_10_DIR, 'tablet_10in');

    await browser.close();
    console.log('\n🎉 All Play Store screenshots captured successfully!');
  } catch (e) {
    console.error('Error capturing screenshots:', e);
    process.exit(1);
  }
})();
