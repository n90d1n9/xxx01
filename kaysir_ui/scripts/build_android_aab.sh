#!/bin/bash

# Extract version from pubspec.yaml
VERSION=$(grep 'version:' pubspec.yaml | sed 's/version: //')
DESTINATION_DIR="$HOME/Library/CloudStorage/Dropbox/000/tsiqahub"

echo "Detected version: $VERSION"

# Build the app bundle
flutter build appbundle --release --no-tree-shake-icons

# Check if build was successful
if [ $? -eq 0 ]; then
    # Define destination
    DEST="$DESTINATION_DIR/tsiqahub-release-v$VERSION.aab"
    
    # Copy the file
    cp build/app/outputs/bundle/release/app-release.aab "$DEST"
    
    echo "✅ Build successful!"
    echo "📂 Copied to: $DEST"
else
    echo "❌ Build failed!"
    exit 1
fi