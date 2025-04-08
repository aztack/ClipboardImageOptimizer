import Foundation
import Cocoa

class ClipboardImageOptimizer {
    private let imageOptimPath = "/Applications/ImageOptim.app/Contents/MacOS/ImageOptim"
    private var tempFilePath: URL?
    private var originalFileSize: Int64 = 0

    func run() {
        print("🔍 Checking clipboard for image data...")

        guard let image = getImageFromClipboard() else {
            print("❌ No image found on clipboard.")
            return
        }

        print("✅ Image found on clipboard.")

        guard let tempFile = saveTempFile(image: image) else {
            print("❌ Failed to save temporary file.")
            return
        }

        tempFilePath = tempFile
        originalFileSize = getFileSize(url: tempFile)
        print("📝 Saved to temporary file: \(tempFile.path)")
        print("📊 Original file size: \(formatFileSize(originalFileSize))")

        print("🚀 Launching ImageOptim...")
        if !optimizeImage(at: tempFile) {
            print("❌ Failed to optimize image.")
            cleanUp()
            return
        }

        print("✅ ImageOptim finished processing.")

        // Get optimized image and copy to clipboard
        guard let optimizedImage = NSImage(contentsOf: tempFile) else {
            print("❌ Failed to load optimized image.")
            cleanUp()
            return
        }

        let optimizedFileSize = getFileSize(url: tempFile)
        print("📊 Optimized file size: \(formatFileSize(optimizedFileSize))")

        if originalFileSize > 0 {
            let compressionRatio = Double(optimizedFileSize) / Double(originalFileSize) * 100
            let savings = 100 - compressionRatio
            print("📉 Compression ratio: \(String(format: "%.2f", compressionRatio))%")
            print("💰 Space saved: \(String(format: "%.2f", savings))%")
        }

        if copyImageToClipboard(image: optimizedImage) {
            print("✅ Optimized image copied back to clipboard.")
        } else {
            print("❌ Failed to copy optimized image to clipboard.")
        }

        cleanUp()
    }

    private func getImageFromClipboard() -> NSImage? {
        let pasteboard = NSPasteboard.general

        guard pasteboard.canReadObject(forClasses: [NSImage.self], options: nil) else {
            return nil
        }

        return pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage
    }

    private func saveTempFile(image: NSImage) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "clipboard_image_\(Int(Date().timeIntervalSince1970)).png"
        let fileURL = tempDir.appendingPathComponent(fileName)

        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            return nil
        }

        do {
            try pngData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving temp file: \(error)")
            return nil
        }
    }

    private func optimizeImage(at url: URL) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: imageOptimPath)
        process.arguments = [url.path]

        do {
            try process.run()
            process.waitUntilExit()

            // Check if ImageOptim exited successfully
            return process.terminationStatus == 0
        } catch {
            print("Error running ImageOptim: \(error)")
            return false
        }
    }

    private func copyImageToClipboard(image: NSImage) -> Bool {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        return pasteboard.writeObjects([image])
    }

    private func getFileSize(url: URL) -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            print("Error getting file size: \(error)")
            return 0
        }
    }

    private func formatFileSize(_ size: Int64) -> String {
        if size < 1024 {
            return "\(size) bytes"
        } else if size < 1024 * 1024 {
            let kb = Double(size) / 1024.0
            return String(format: "%.2f KB", kb)
        } else {
            let mb = Double(size) / (1024.0 * 1024.0)
            return String(format: "%.2f MB", mb)
        }
    }

    private func cleanUp() {
        if let path = tempFilePath {
            do {
                try FileManager.default.removeItem(at: path)
                print("🧹 Temporary file removed.")
            } catch {
                print("⚠️ Failed to remove temporary file: \(error)")
            }
        }
    }
}

// Main program
print("📋 ImageOptim Clipboard Optimizer")
print("--------------------------------")

let optimizer = ClipboardImageOptimizer()
optimizer.run()