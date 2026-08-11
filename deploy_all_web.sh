#!/bin/bash
set -e

export CLOUDFLARE_ACCOUNT_ID="cdbd00e3efae5135a49ed13ac47e0f68"
export CLOUDFLARE_API_KEY="ccc371fcab3109566b511d898831bf36a1e00"
export CLOUDFLARE_EMAIL="sientey@hotmail.com"

echo "🧹 Cleaning previous build caches..."
flutter clean
flutter pub get

echo "Building Family Web (family.tiknetafrica.com)..."
cp web/manifest_family.json web/manifest.json
cp web/icons/family/Icon-192.png web/favicon.png
cp web/icons/family/Icon-192.png web/icons/Icon-192.png
cp web/icons/family/Icon-512.png web/icons/Icon-512.png
cp web/icons/family/Icon-maskable-192.png web/icons/Icon-maskable-192.png
cp web/icons/family/Icon-maskable-512.png web/icons/Icon-maskable-512.png
flutter build web --release -t lib/main_family.dart --dart-define=APP_VARIANT=family
cp web/_headers build/web/_headers
cp web/_redirects build/web/_redirects 2>/dev/null || true
echo "Deploying Family Web to project 'family' (family.tiknetafrica.com)..."
npx wrangler pages deploy build/web --project-name family

echo "Building Campus Web (campus.tiknetafrica.com)..."
cp web/manifest_campus.json web/manifest.json
cp web/icons/campus/Icon-192.png web/favicon.png
cp web/icons/campus/Icon-192.png web/icons/Icon-192.png
cp web/icons/campus/Icon-512.png web/icons/Icon-512.png
cp web/icons/campus/Icon-maskable-192.png web/icons/Icon-maskable-192.png
cp web/icons/campus/Icon-maskable-512.png web/icons/Icon-maskable-512.png
flutter build web --release -t lib/main_campus.dart --dart-define=APP_VARIANT=campus
cp web/_headers build/web/_headers
cp web/_redirects build/web/_redirects 2>/dev/null || true
echo "Deploying Campus Web to project 'campus'..."
npx wrangler pages deploy build/web --project-name campus

echo "Building Partner Web (partner.tiknetafrica.com)..."
cp web/manifest_partner.json web/manifest.json
cp web/icons/partner/Icon-192.png web/favicon.png
cp web/icons/partner/Icon-192.png web/icons/Icon-192.png
cp web/icons/partner/Icon-512.png web/icons/Icon-512.png
cp web/icons/partner/Icon-maskable-192.png web/icons/Icon-maskable-192.png
cp web/icons/partner/Icon-maskable-512.png web/icons/Icon-maskable-512.png
flutter build web --release -t lib/main_partner.dart --dart-define=APP_VARIANT=partner
cp web/_headers build/web/_headers
cp web/_redirects build/web/_redirects 2>/dev/null || true
echo "Deploying Partner Web to project 'partner'..."
npx wrangler pages deploy build/web --project-name partner

echo "All web deployments finished!"
