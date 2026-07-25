import os
import subprocess

PHONE_DIR = 'store_assets/phone'
TABLET_7_DIR = 'store_assets/tablet_7inch'
TABLET_10_DIR = 'store_assets/tablet_10inch'

for d in [PHONE_DIR, TABLET_7_DIR, TABLET_10_DIR]:
    os.makedirs(d, exist_ok=True)

configs = [
    # Phone Screenshots (1080 x 1920 px - 9:16 aspect ratio)
    {'name': f'{PHONE_DIR}/screenshot_1_home.png', 'w': 1080, 'h': 1920, 'url': 'http://localhost:8080'},
    {'name': f'{PHONE_DIR}/screenshot_2_currency.png', 'w': 1080, 'h': 1920, 'url': 'http://localhost:8080'},
    
    # 7-inch Tablet Screenshots (1200 x 1920 px - 9:16 aspect ratio)
    {'name': f'{TABLET_7_DIR}/screenshot_1_home.png', 'w': 1200, 'h': 1920, 'url': 'http://localhost:8080'},
    {'name': f'{TABLET_7_DIR}/screenshot_2_currency.png', 'w': 1200, 'h': 1920, 'url': 'http://localhost:8080'},

    # 10-inch Tablet Screenshots (1600 x 2560 px - 9:16 aspect ratio)
    {'name': f'{TABLET_10_DIR}/screenshot_1_home.png', 'w': 1600, 'h': 2560, 'url': 'http://localhost:8080'},
    {'name': f'{TABLET_10_DIR}/screenshot_2_currency.png', 'w': 1600, 'h': 2560, 'url': 'http://localhost:8080'},
]

print("🚀 Capturing high-resolution Play Store screenshots from live Flutter app...")

for c in configs:
    cmd = [
        'google-chrome',
        '--headless=new',
        '--disable-gpu',
        '--virtual-time-budget=4000',
        f"--window-size={c['w']},{c['h']}",
        f"--screenshot={c['name']}",
        c['url']
    ]
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if os.path.exists(c['name']):
        size_kb = os.path.getsize(c['name']) / 1024
        print(f"  ✓ Captured {c['name']} ({c['w']}x{c['h']}) — {size_kb:.1f} KB")
    else:
        print(f"  ✗ Failed {c['name']}")

print("\n✨ All Play Store screenshots successfully generated!")
