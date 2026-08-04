#!/bin/bash
set -e

echo "Building Family Web..."
flutter build web -t lib/main_family.dart
echo "Deploying Family Web..."
wrangler pages deploy build/web --project-name family

echo "Building Campus Web..."
flutter build web -t lib/main_campus.dart
echo "Deploying Campus Web..."
wrangler pages deploy build/web --project-name campus

echo "Building Partner Web..."
flutter build web -t lib/main_partner.dart
echo "Deploying Partner Web..."
wrangler pages deploy build/web --project-name partner

echo "All web deployments finished!"
