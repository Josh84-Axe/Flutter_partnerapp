import asyncio
import time
from playwright.async_api import async_playwright

URLS = {
    "Partner": "https://partner-bjo.pages.dev",
    "Family": "https://family-3qj.pages.dev",
    "Campus": "https://campus-8xr.pages.dev",
}

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(
            headless=True,
            args=[
                "--disable-blink-features=AutomationControlled",
                "--no-sandbox"
            ]
        )
        context = await browser.new_context(
            user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
        )
        page = await context.new_page()
        
        print("\n⚡ [Playwright Stealth Benchmark] Testing Build 1.2.239\n" + "="*60)
        
        for name, url in URLS.items():
            start = time.time()
            try:
                # Wait for initial HTML response commit
                response = await page.goto(url, wait_until="commit", timeout=15000)
                html_time = round((time.time() - start) * 1000, 2)
                
                # Check for Flutter engine load
                await asyncio.sleep(2)
                total_time = round((time.time() - start) * 1000, 2)
                
                title = await page.title()
                loader_present = await page.evaluate("() => !!document.getElementById('loading')")
                
                print(f"✅ {name} ({url}):")
                print(f"   ├─ Status: {response.status}")
                print(f"   ├─ Title: {title}")
                print(f"   ├─ First HTML Response: {html_time} ms ({round(html_time/1000, 2)}s)")
                print(f"   ├─ Flutter Engine Rendered: {total_time} ms ({round(total_time/1000, 2)}s)")
                print(f"   └─ HTML Loader Cleared: {'YES' if not loader_present else 'NO'}")
                print("-" * 60)
            except Exception as e:
                print(f"❌ {name} Error: {e}")

        await browser.close()

if __name__ == "__main__":
    asyncio.run(main())
