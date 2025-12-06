import json
import re
import os

def normalize_path(path):
    # Convert all {param} to {param} to ignore parameter name differences
    return re.sub(r'\{[^}]+\}', '{param}', path).rstrip('/')

def load_swagger_endpoints(filepath):
    endpoints = set()
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
            for path, methods in data.get('paths', {}).items():
                for method in methods.keys():
                    # Swagger methods are lowercase, we'll use uppercase
                    endpoints.add((method.upper(), normalize_path(path)))
    except Exception as e:
        print(f"Error loading Swagger: {e}")
    return endpoints

def load_implemented_endpoints(filepath):
    endpoints = set()
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            # Look for lines like "- `POST /partner/login/`"
            matches = re.findall(r'- `([A-Z]+) ([^`]+)`', content)
            for method, path in matches:
                endpoints.add((method, normalize_path(path)))
    except Exception as e:
        print(f"Error loading implemented APIs: {e}")
    return endpoints

def generate_report(swagger_eps, implemented_eps):
    missing_in_code = sorted(list(swagger_eps - implemented_eps))
    extra_in_code = sorted(list(implemented_eps - swagger_eps))
    matched = sorted(list(swagger_eps.intersection(implemented_eps)))

    report = "# API Audit Report\n\n"
    
    report += f"Total Swagger Endpoints: {len(swagger_eps)}\n"
    report += f"Total Implemented Endpoints: {len(implemented_eps)}\n"
    report += f"Matched Endpoints: {len(matched)}\n\n"

    report += "## ❌ Missing in Codebase (Implemented in Swagger but not found in Code)\n"
    if missing_in_code:
        for method, path in missing_in_code:
            report += f"- `[{method}] {path}`\n"
    else:
        report += "None! All Swagger endpoints are implemented.\n"
    
    report += "\n## ⚠️ Extra in Codebase (Found in Code but not in Swagger)\n"
    if extra_in_code:
        for method, path in extra_in_code:
            report += f"- `[{method}] {path}`\n"
    else:
        report += "None! No extra endpoints found in code.\n"

    return report

def main():
    base_dir = r"C:\Users\ELITEX21012G2\.gemini\antigravity\brain\2400cc73-ffee-4ecb-8a42-7a7f4b50de42"
    swagger_file = os.path.join(base_dir, "swagger.json")
    implemented_file = os.path.join(base_dir, "implemented_apis.md")
    output_file = os.path.join(base_dir, "api_audit_report.md")

    print(f"Loading Swagger from {swagger_file}...")
    swagger_eps = load_swagger_endpoints(swagger_file)
    
    print(f"Loading Implemented APIs from {implemented_file}...")
    implemented_eps = load_implemented_endpoints(implemented_file)

    print("Generating report...")
    report = generate_report(swagger_eps, implemented_eps)

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"Report saved to {output_file}")
    print(report)

if __name__ == "__main__":
    main()
