#!/bin/bash

# Configuration
PROJECT_NAME="wifi-4u-partner"
ACCOUNT_ID="cdbd00e3efae5135a49ed13ac47e0f68"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting Production Promotion...${NC}"

# Check for API Token
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo -e "${RED}❌ CLOUDFLARE_API_TOKEN is not set.${NC}"
    echo "Please run: export CLOUDFLARE_API_TOKEN=your_token_here"
    exit 1
fi

# Build
echo -e "${BLUE}📦 Building Flutter Web App...${NC}"
flutter build web --release \
  --dart-define=API_HOST=https://api.tiknetafrica.com \
  --dart-define=CRM_API_KEY=aPuOwuzgw2HWPiWuVM5AcwexsVNiKKJkqEWXFHN2nHE \
  --dart-define=USE_REMOTE_API=true

# Create version.json
VERSION=$(grep -o "BUILD v[0-9.]*" build/web/index.html | cut -d'v' -f2)
echo "{\"latestVersion\": \"$VERSION\", \"downloadUrl\": \"https://github.com/Josh84-Axe/Flutter_partnerapp/releases/tag/v$VERSION\", \"forceUpdate\": false}" > build/web/version.json

# Deploy
echo -e "${BLUE}☁️ Deploying to Cloudflare Pages...${NC}"
# We try to deploy to 'main'. If 'main' is not production, we should update project settings.
# Tip: wrangler pages deploy build/web --project-name=wifi-4u-partner --branch=main
npx wrangler pages deploy build/web --project-name=$PROJECT_NAME --branch=main

echo -e "${GREEN}✅ Deployment triggered. Check https://partner.wifi-4u.net in a few minutes.${NC}"
echo -e "${BLUE}💡 Note: If propagation still fails, ensure 'main' is set as the Production branch in the Cloudflare Pages Dashboard.${NC}"
