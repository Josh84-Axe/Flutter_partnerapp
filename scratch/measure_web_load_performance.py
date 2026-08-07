import asyncio
import time
from playwright.async_api import async_playwright

URLS = {
    "Partner": "https://partner-bjo.pages.dev",
    "Family": "https://family-3qj.pages.dev",
    "Campus": "https://campus-8xr.pages.dev",
}

async def test_performance():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        
        print("\n🚀 [Playwright QA Benchmark] Build 1.2.239 Performance Verification\n" + "="*70)
        
        for name, url in URLS.items():
            context = await browser.new_context()
            page = await context.new_page()
            
            # --- 1. Cold Load (Initial Visit) ---
            start_cold = time.time()
            try:
                response = await page.goto(url, wait_until="commit", timeout=15000)
                await page.wait_for_selector('flt-glass-pane, canvas, flutter-view, #loading', timeout=10000)
                cold_time = round((time.time() - start_cold) * 1000, 2)
                status = response.status if response else "Unknown"
            except Exception as e:
                cold_time = f"Error ({e})"
                status = "Failed"

            # --- 2. Warm Load (Cached Repeat Visit) ---
            start_warm = time.time()
            try:
                await page.reload(wait_until="commit", timeout=10000)
                await page.wait_for_selector('flt-glass-pane, canvas, flutter-view, #loading', timeout=10000)
                warm_time = round((time.time() - start_warm) * 1000, 2)
            except Exception as e:
                warm_time = f"Error ({e})"

            # --- 3. Check Loading Overlay Status ---
            try:
                loading_hidden = await page.evaluate("() => !document.getElementById('loading') || document.getElementById('loading').style.opacity === '0'")
            except Exception:
                loading_hidden = False

            print(f"📱 Variant: {name} ({url})")
            print(f"   ├─ HTTP Status: {status}")
            print(f"   ├─ Cold First Visit Render: {cold_time} ms ({round(cold_time/1000, 2) if isinstance(cold_time, float) else cold_time}s)")
            print(f"   ├─ Warm Repeat Load (Cached): {warm_time} ms ({round(warm_time/1000, 2) if isinstance(warm_time, float) else warm_time}s)")
            print(f"   └─ HTML Loader Dismissed: {'✅ YES' if loading_hidden else '❌ NO'}")
            print("-" * 70)
            
            await context.close()
            
        await browser.close()

if __name__ == "__main__":
    asyncio.run(test_performance())
