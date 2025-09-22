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

    # Copy app icon
    if [ -f "logo-md.png" ]; then
        cp logo-md.png MarkdownReader.app/Contents/Resources/AppIcon.png
        echo "🎨 Added app icon"
    fi

    echo "✅ App bundle created: MarkdownReader.app"
    echo "🚀 You can now double-click MarkdownReader.app to run the application!"
else
    echo "❌ Build failed!"
    exit 1
fi