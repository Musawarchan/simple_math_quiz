#!/bin/bash

# Math Drill MVP - Build Script for Web Deployment
echo "Building Math Drill MVP for web deployment..."

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build for web
flutter build web --release

echo "Build completed! Web files are in the 'build/web' directory."
echo "You can deploy the contents of 'build/web' to any web server."
echo ""
echo "To test locally, run: flutter run -d web-server --web-port 8080"
