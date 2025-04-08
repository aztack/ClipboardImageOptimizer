#!/bin/bash

# Set to exit on error
set -e

echo "📦 Building ClipboardImageOptimizer..."

# Navigate to project directory (update path as needed)
# cd /path/to/ClipboardImageOptimizer

# Build in release mode
swift build -c release

# Get the path to the compiled binary
BINARY_PATH=$(swift build -c release --show-bin-path)/ClipboardImageOptimizer

echo "✅ Binary built at: $BINARY_PATH"

# Create a directory for the final product
mkdir -p ./dist

# Copy to a distribution folder with a simpler name
cp "$BINARY_PATH" ./dist/ImageOptimizer

# Make it executable
chmod +x ./dist/ImageOptimizer

echo "✅ Executable created at: ./dist/ImageOptimizer"

# Optional: Create a compressed archive
cd ./dist
zip ImageOptimizer.zip ImageOptimizer
cd ..

echo "✅ Distribution zip created at: ./dist/ImageOptimizer.zip"
echo "🎉 Done! You can distribute the executable or the zip file."