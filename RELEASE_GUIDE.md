# 🚀 Fluid App Release Guide - Complete End-to-End Setup

This guide covers everything you need to know to set up automatic updates for your Fluid dictation app.

## 📋 **Current Configuration**

- **GitHub Repository**: `https://github.com/altic-dev/fluid`
- **Owner**: `altic-dev`
- **Repository Name**: `fluid`
- **Current Version**: `1.1` (as set in Info.plist)

## 🔧 **1. AppUpdater Setup (Already Done!)**

✅ **AppUpdater Integration Complete**:
- Added as Swift Package dependency
- Configured in AppDelegate with automatic daily checks
- Manual update check available in menu bar
- Error handling and user notifications implemented

## 📦 **2. Building and Packaging Your App**

### **Build Steps:**
1. **Set Release Configuration**:
   ```bash
   # In Xcode, change scheme to "Release" mode
   # Or via command line:
   xcodebuild -project Fluid.xcodeproj -scheme Fluid -configuration Release clean build
   ```

2. **Archive Your App**:
   ```bash
   # Create an archive
   xcodebuild -project Fluid.xcodeproj -scheme Fluid -configuration Release archive -archivePath build/Fluid.xcarchive
   
   # Export the app
   xcodebuild -exportArchive -archivePath build/Fluid.xcarchive -exportPath build/Release -exportOptionsPlist ExportOptions.plist
   ```

3. **Create Release ZIP**:
   ```bash
   # Navigate to your exported app
   cd build/Release
   
   # Create zip with EXACT naming convention
   zip -r fluid-1.1.zip Fluid.app
   ```

## 🎯 **3. GitHub Release Setup**

### **Critical Requirements:**

#### **A. Asset Naming Convention**
AppUpdater expects this EXACT format:
```
{repo-name}-{version}.{extension}
```

**Examples:**
- ✅ `fluid-1.1.zip`
- ✅ `fluid-1.2.zip` 
- ✅ `fluid-2.0.zip`
- ❌ `Fluid-1.1.zip` (wrong case)
- ❌ `fluid-v1.1.zip` (extra 'v')
- ❌ `fluid_1.1.zip` (underscore instead of dash)

#### **B. Version Matching**
The release tag must match your `CFBundleShortVersionString` in Info.plist:

**Info.plist:**
```xml
<key>CFBundleShortVersionString</key>
<string>1.1</string>
```

**GitHub Release Tag:**
```
v1.1  (recommended)
or
1.1   (also works)
```

### **Creating a Release:**

1. **Go to your repository**: `https://github.com/altic-dev/fluid/releases`

2. **Click "Create a new release"**

3. **Fill out the release:**
   ```
   Tag: v1.1
   Title: Fluid v1.1 - Parakeet TDT v3 with Multi-Language Support
   Description: 
   ## 🎉 What's New in v1.1
   
   - **Upgraded to Parakeet TDT v3** with unified model architecture
   - **25 European languages** with auto-detection support
   - **Enhanced UI** with language selection and documentation links
   - **Improved error handling** and logging
   - **Automatic updates** - this is the first version with auto-update capability!
   
   ## 🚀 Installation
   1. Download `fluid-1.1.zip`
   2. Extract and move `Fluid.app` to your Applications folder
   3. Run the app and grant accessibility permissions when prompted
   
   ## 🔧 System Requirements
   - macOS 13.0 or later
   - Apple Silicon or Intel Mac
   ```

4. **Upload your zip file**: Drag `fluid-1.1.zip` to the release assets

5. **Publish the release**

## 📅 **4. Future Release Process**

For version 1.2 and beyond:

### **Step 1: Update Version Numbers**
```xml
<!-- In Info.plist -->
<key>CFBundleVersion</key>
<string>2</string>  <!-- Increment build number -->
<key>CFBundleShortVersionString</key>
<string>1.2</string>  <!-- New version -->
```

### **Step 2: Build and Package**
```bash
# Build release version
xcodebuild -project Fluid.xcodeproj -scheme Fluid -configuration Release clean build

# Create zip with new version number
zip -r fluid-1.2.zip Fluid.app
```

### **Step 3: Create GitHub Release**
- **Tag**: `v1.2`
- **Asset**: `fluid-1.2.zip`
- **Title**: `Fluid v1.2 - [Your New Features]`

## 🔍 **5. Testing the Update System**

### **Manual Testing:**
1. Install version 1.1 on your Mac
2. Create a test release 1.2
3. Click "Check for Updates..." in the menu bar
4. Verify the update downloads and installs correctly

### **Automatic Testing:**
- AppUpdater checks daily automatically
- Users will get updates silently
- No user interaction required for updates

## ⚙️ **6. Advanced Configuration**

### **Code Signing (Recommended)**
AppUpdater verifies code signatures for security:
```bash
# Sign your app before zipping
codesign --force --deep --sign "Developer ID Application: Your Name" Fluid.app
```

### **Notarization (For Distribution)**
```bash
# Notarize for macOS Gatekeeper
xcrun notarytool submit fluid-1.1.zip --apple-id your-email@example.com --team-id YOUR_TEAM_ID --wait
```

## 🎯 **7. Repository Structure**

Your repository should look like this:
```
fluid/
├── Sources/
├── Info.plist
├── README.md
├── RELEASE_GUIDE.md  ← This file
└── releases/
    ├── v1.1/
    │   └── fluid-1.1.zip
    └── v1.2/
        └── fluid-1.2.zip
```

## 🚨 **8. Troubleshooting**

### **Common Issues:**

**AppUpdater says "no updates available" but there's a new release:**
- Check asset naming: must be `fluid-{version}.zip`
- Verify version in Info.plist matches release tag
- Ensure release is published (not draft)

**Update fails to install:**
- Check code signing matches
- Verify app isn't running during update
- Check file permissions

**Manual update check doesn't work:**
- Verify AppDelegate is properly connected
- Check menu bar action is calling the right method
- Look at console logs for errors

## ✅ **9. Verification Checklist**

Before each release:
- [ ] Version updated in Info.plist
- [ ] App builds successfully in Release configuration
- [ ] Asset named correctly: `fluid-{version}.zip`
- [ ] Release tag matches Info.plist version
- [ ] Release description includes changelog
- [ ] Asset uploaded to GitHub release
- [ ] Release published (not draft)
- [ ] Manual update check tested
- [ ] App functionality verified after update

## 🎉 **Success!**

Your app now has:
- ✅ Automatic daily update checks
- ✅ Manual update checking via menu bar
- ✅ Silent update installation
- ✅ Error handling and user notifications
- ✅ Proper version management
- ✅ Complete end-to-end update pipeline

Users will now receive updates automatically without any manual intervention! 🚀
