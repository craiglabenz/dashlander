#!/bin/bash
set -e

echo "Building Flutter app..."
# ./build_flutter.sh

echo "Building Jaspr site..."
jaspr build

echo "Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo "Deployment complete!"
