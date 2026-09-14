#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================================="
echo "🛠️  Building Tiknet Router Provisioning Agent for macOS..."
echo "=========================================================="

mkdir -p build/dmg_root

echo "📦 Compiling native AOT executable with Dart..."
dart compile exe bin/tiknet_agent.dart -o build/dmg_root/tiknet_agent
chmod +x build/dmg_root/tiknet_agent

# Create launch script inside DMG
cat << 'LAUNCHER' > build/dmg_root/run_agent.command
#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$DIR/tiknet_agent"
LAUNCHER
chmod +x build/dmg_root/run_agent.command

# Create README inside DMG
cat << 'README' > build/dmg_root/README.txt
Tiknet Local Router Provisioning Agent v1.0.2
============================================
Double-click 'run_agent.command' to start the local provisioning agent.
The agent will listen on http://localhost:9876 to facilitate automated
router onboarding via the Tiknet Web Dashboard or Captive Portal.
README

echo "💿 Packaging into TiknetAgent.dmg..."
rm -f build/TiknetAgent.dmg
hdiutil create -volname "TiknetAgent" -srcfolder build/dmg_root -ov -format UDZO build/TiknetAgent.dmg

echo "✅ macOS DMG built successfully: $SCRIPT_DIR/build/TiknetAgent.dmg"
ls -lh build/TiknetAgent.dmg
