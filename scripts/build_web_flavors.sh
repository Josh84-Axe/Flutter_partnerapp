#!/bin/bash

# Build Script for Web PWA Flavors
# Usage: ./scripts/build_web_flavors.sh <flavor_name>
# Example: ./scripts/build_web_flavors.sh family

FLAVOR=$1

if [ -z "$FLAVOR" ]; then
  echo "Usage: ./scripts/build_web_flavors.sh <flavor_name>"
  echo "Available flavors: partner, family, campus"
  exit 1
fi

echo "Building Web PWA for flavor: $FLAVOR"

# 1. We could swap out the manifest.json here before building
if [ -f "web/manifest_$FLAVOR.json" ]; then
  echo "Swapping manifest.json for $FLAVOR"
  cp "web/manifest_$FLAVOR.json" "web/manifest.json"
fi

# 2. Build the Flutter web app with the dart-define injected
flutter build web --release --dart-define=APP_VARIANT=$FLAVOR

# 3. Rename the build folder so it doesn't get overwritten by the next build
if [ -d "build/web" ]; then
  rm -rf "build/web_$FLAVOR"
  mv "build/web" "build/web_$FLAVOR"
  echo "✅ Build completed successfully and moved to build/web_$FLAVOR"
else
  echo "❌ Build failed. Directory build/web not found."
fi
