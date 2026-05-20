#!/bin/bash
set -e

echo "Building Flutter web app..."
cd ../app

echo "Generating version file..."
dart tool/update_version.dart

flutter build web --base-href "/app/"

echo "Copying build output to Jaspr site..."
rm -rf ../site/web/app
cp -R build/web ../site/web/app

echo "Integration complete. The Flutter app is now available at /app/"

