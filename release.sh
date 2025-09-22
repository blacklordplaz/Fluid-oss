#!/bin/bash

set -e  # Exit on any error

echo "🚀 Starting Fluid release process..."

# Get version from Info.plist
VERSION=$(plutil -p Info.plist | grep CFBundleShortVersionString | cut -d '"' -f 4)
echo "📋 Release version: $VERSION"

# Build app in Release mode
echo "🔨 Building app in Release configuration..."
xcodebuild -project Fluid.xcodeproj -scheme Fluid -configuration Release clean build

# Find the built app
APP_PATH="build/Release/Fluid.app"
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: Built app not found at $APP_PATH"
    exit 1
fi

# Create zip with exact naming convention
ZIP_NAME="Fluid-oss-${VERSION}.zip"
echo "📦 Creating release zip: $ZIP_NAME"
cd build/Release
zip -r "../../$ZIP_NAME" Fluid.app
cd ../..

# Verify zip was created
if [ ! -f "$ZIP_NAME" ]; then
    echo "❌ Error: Failed to create zip file"
    exit 1
fi

echo "✅ Zip created successfully: $ZIP_NAME"

# Create DMG (traditional macOS installer)
DMG_NAME="Fluid-oss-${VERSION}.dmg"
echo "💿 Creating DMG: $DMG_NAME"

create-dmg \
  --volname "Fluid Installer" \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "Fluid.app" 150 150 \
  --hide-extension "Fluid.app" \
  --app-drop-link 400 150 \
  "$DMG_NAME" \
  "Fluid.app"

echo "✅ DMG created successfully: $DMG_NAME"

# Create GitHub release
echo "📤 Creating GitHub release..."
gh release create "v$VERSION" "$ZIP_NAME" "$DMG_NAME" \
  --title "Fluid v$VERSION - Parakeet TDT v3 with Multi-Language Support" \
  --notes "\
## 🎉 What's New in v$VERSION

- **Upgraded to Parakeet TDT v3** with unified model architecture
- **25 European languages** with auto-detection support
- **Enhanced UI** with language selection and documentation links
- **Improved error handling** and logging
- **Automatic updates** - seamless update experience!

## 🚀 Installation Options

### Option 1: ZIP (Recommended for Auto-Updates)
1. Download \`$ZIP_NAME\`
2. Extract and move \`Fluid.app\` to your Applications folder
3. Run the app - updates will be automatic!

### Option 2: DMG (Traditional Installer)
1. Download \`$DMG_NAME\`
2. Double-click to mount and drag \`Fluid.app\` to Applications
3. Run the app and grant accessibility permissions

## 🔧 System Requirements
- macOS 13.0 or later
- Apple Silicon or Intel Mac

## 📦 Asset Details
- **ZIP**: \`$ZIP_NAME\` ($(du -h "$ZIP_NAME" | cut -f1))
  - SHA256: $(shasum -a 256 "$ZIP_NAME" | cut -d' ' -f1)
- **DMG**: \`$DMG_NAME\` ($(du -h "$DMG_NAME" | cut -f1))
  - SHA256: $(shasum -a 256 "$DMG_NAME" | cut -d' ' -f1)
"

echo "✅ Release v$VERSION created successfully!"
echo "🔗 Release URL: https://github.com/altic-dev/Fluid-oss/releases/tag/v$VERSION"
echo "📁 Assets: $ZIP_NAME and $DMG_NAME"

# Clean up
echo "🧹 Cleaning up..."
rm "$ZIP_NAME" "$DMG_NAME"

echo "🎉 Release process completed successfully!"
