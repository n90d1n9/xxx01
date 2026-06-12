#!/bin/bash

# Extract version from pubspec.yaml
VERSION=$(grep 'version:' pubspec.yaml | sed 's/version: //')

echo "Detected version: $VERSION"

# Build the APK (Fat APK for universal compatibility)
flutter build apk --release --no-tree-shake-icons

# Check if build was successful
if [ $? -eq 0 ]; then
    # Define destination
    DEST="$HOME/Library/CloudStorage/Dropbox/000/tsiqahub/tsiqahub-release-v$VERSION.apk"
    
    # Copy the file
    # Note: APK output path is different from AAB
    cp build/app/outputs/flutter-apk/app-release.apk "$DEST"
    
    echo "✅ Build successful!"
    echo "📂 Copied to: $DEST"
else
    echo "❌ Build failed!"
    exit 1
fi
