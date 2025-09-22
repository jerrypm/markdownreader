#!/bin/bash

echo "🔨 Building Markdown Reader..."

# Clean previous builds
rm -rf .build
rm -rf MarkdownReader.app

# Build the Swift package
echo "📦 Compiling Swift code..."
swift build -c release

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"

    # Create app bundle
    echo "📱 Creating macOS app bundle..."
    mkdir -p MarkdownReader.app/Contents/MacOS
    mkdir -p MarkdownReader.app/Contents/Resources

    # Copy executable
    cp .build/release/MarkdownReader MarkdownReader.app/Contents/MacOS/

    # Create and copy app icon
    if [ -f "logo-md.png" ]; then
        echo "🎨 Creating app icon..."

        # Create iconset directory
        rm -rf AppIcon.iconset
        mkdir -p AppIcon.iconset

        # Generate all required icon sizes using sips
        sips -z 16 16 logo-md.png --out AppIcon.iconset/icon_16x16.png > /dev/null 2>&1
        sips -z 32 32 logo-md.png --out AppIcon.iconset/icon_16x16@2x.png > /dev/null 2>&1
        sips -z 32 32 logo-md.png --out AppIcon.iconset/icon_32x32.png > /dev/null 2>&1
        sips -z 64 64 logo-md.png --out AppIcon.iconset/icon_32x32@2x.png > /dev/null 2>&1
        sips -z 128 128 logo-md.png --out AppIcon.iconset/icon_128x128.png > /dev/null 2>&1
        sips -z 256 256 logo-md.png --out AppIcon.iconset/icon_128x128@2x.png > /dev/null 2>&1
        sips -z 256 256 logo-md.png --out AppIcon.iconset/icon_256x256.png > /dev/null 2>&1
        sips -z 512 512 logo-md.png --out AppIcon.iconset/icon_256x256@2x.png > /dev/null 2>&1
        sips -z 512 512 logo-md.png --out AppIcon.iconset/icon_512x512.png > /dev/null 2>&1
        sips -z 1024 1024 logo-md.png --out AppIcon.iconset/icon_512x512@2x.png > /dev/null 2>&1

        # Create .icns file
        iconutil -c icns AppIcon.iconset

        # Copy to app bundle
        cp AppIcon.icns MarkdownReader.app/Contents/Resources/

        # Clean up temporary files
        rm -rf AppIcon.iconset

        echo "✅ App icon created and installed"
    fi

    # Create Info.plist
    cat > MarkdownReader.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>MarkdownReader</string>
    <key>CFBundleIdentifier</key>
    <string>com.jpm.MarkdownReader</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Markdown Reader</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon.icns</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
    </dict>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Markdown Document</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>net.daringfireball.markdown</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF

    echo "✅ App bundle created: MarkdownReader.app"
    echo "🚀 You can now double-click MarkdownReader.app to run the application!"
else
    echo "❌ Build failed!"
    exit 1
fi