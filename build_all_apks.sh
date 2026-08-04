#!/bin/bash
set -e

echo "Building Partner APK..."
flutter build apk -t lib/main_partner.dart --flavor partner
echo "✅ Partner APK Built"

echo "Building Family APK..."
flutter build apk -t lib/main_family.dart --flavor family
echo "✅ Family APK Built"

echo "Building Campus APK..."
flutter build apk -t lib/main_campus.dart --flavor campus
echo "✅ Campus APK Built"

echo "All builds completed!"
