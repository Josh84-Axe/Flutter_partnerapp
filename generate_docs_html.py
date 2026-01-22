import os
import base64

# Configuration
DOCS_DIR = 'docs'
FILES = [
    'USER_MANUAL_EN', 'USER_MANUAL_FR',
    'TEST_SCENARIOS_EN', 'TEST_SCENARIOS_FR',
    'TESTER_FEEDBACK_FORM_EN', 'TESTER_FEEDBACK_FORM_FR'
]

# HTML Template with marked.js and basic styling
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title}</title>
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <style>
        body {{
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji";
            line-height: 1.6;
            color: #24292f;
            max-width: 800px;
            margin: 0 auto;
            padding: 40px 20px;
        }}
        h1, h2, h3 {{ border-bottom: 1px solid #eaecef; padding-bottom: .3em; }}
        table {{ border-collapse: collapse; width: 100%; margin-bottom: 16px; }}
        th, td {{ padding: 6px 13px; border: 1px solid #dfe2e5; }}
        tr:nth-child(2n) {{ background-color: #f6f8fa; }}
        code {{ background-color: rgba(27,31,35,.05); padding: .2em .4em; border-radius: 3px; font-family: ui-monospace, SFMono-Regular, SF Mono, Menlo, Consolas, Liberation Mono, monospace; }}
        blockquote {{ border-left: .25em solid #dfe2e5; color: #6a737d; padding: 0 1em; margin: 0; }}
        img {{ max-width: 100%; box-sizing: content-box; background-color: #fff; }}
    </style>
</head>
<body>
    <div id="content"></div>
    <script>
        function b64ToUtf8(str) {{
            const binString = atob(str);
            const bytes = new Uint8Array(binString.length);
            for (let i = 0; i < binString.length; i++) {{
                bytes[i] = binString.charCodeAt(i);
            }}
            return new TextDecoder().decode(bytes);
        }}
        
        const b64_content = "{b64_content}";
        document.getElementById('content').innerHTML = marked.parse(b64ToUtf8(b64_content));
    </script>
</body>
</html>
"""

def generate_htmls():
    for filename in FILES:
        md_path = os.path.join(DOCS_DIR, f"{filename}.md")
        html_path = os.path.join(DOCS_DIR, f"{filename}.html")
        
        if not os.path.exists(md_path):
            print(f"Skipping {md_path} (File not found)")
            continue
            
        with open(md_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        b64_content = base64.b64encode(content.encode('utf-8')).decode('utf-8')
        
        html_content = HTML_TEMPLATE.format(
            title=filename.replace('_', ' '),
            b64_content=b64_content
        )
        
        with open(html_path, 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        print(f"Generated {html_path}")

if __name__ == "__main__":
    generate_htmls()
