import AppKit
import ImageIO
import UniformTypeIdentifiers

let width = 900
let height = 460
let titleBarHeight: CGFloat = 44
let windowControlSize: CGFloat = 12
let framesPerSecond = 12.0
let playbackSpeed = 2.0
let timelineDuration = 8.5
let additionalCursorBlinkDuration = 1.0
let duration = timelineDuration / playbackSpeed + additionalCursorBlinkDuration
let frameCount = Int(duration * framesPerSecond)
let outputURL = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "docs/assets/demo.gif")

let destination = CGImageDestinationCreateWithURL(
    outputURL as CFURL,
    UTType.gif.identifier as CFString,
    frameCount,
    nil
)!

CGImageDestinationSetProperties(destination, [
    kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]
] as CFDictionary)

let font = NSFont.monospacedSystemFont(ofSize: 23, weight: .regular)
let foreground = NSColor(calibratedRed: 0.86, green: 0.89, blue: 0.92, alpha: 1)
let green = NSColor(calibratedRed: 0.31, green: 0.78, blue: 0.47, alpha: 1)
let blue = NSColor(calibratedRed: 0.38, green: 0.67, blue: 0.96, alpha: 1)

func typed(_ text: String, from start: Double, at time: Double, speed: Double = 0.055) -> String {
    let count = max(0, min(text.count, Int((time - start) / speed)))
    return String(text.prefix(count))
}

func draw(_ text: String, x: CGFloat, y: CGFloat, color: NSColor, using selectedFont: NSFont = font) {
    (text as NSString).draw(
        at: NSPoint(x: x, y: CGFloat(height) - y - selectedFont.pointSize - 4),
        withAttributes: [.font: selectedFont, .foregroundColor: color]
    )
}

func drawToast(_ text: String) {
    let toastFont = NSFont.systemFont(ofSize: 17, weight: .medium)
    let textSize = (text as NSString).size(withAttributes: [.font: toastFont])
    let horizontalPadding: CGFloat = 20
    let toastWidth = textSize.width + horizontalPadding * 2
    let toastHeight: CGFloat = 44
    let toastRect = NSRect(
        x: CGFloat(width) - toastWidth - 28,
        y: 28,
        width: toastWidth,
        height: toastHeight
    )

    NSColor(calibratedRed: 0.16, green: 0.19, blue: 0.24, alpha: 1).setFill()
    NSBezierPath(roundedRect: toastRect, xRadius: 10, yRadius: 10).fill()
    draw(
        text,
        x: toastRect.minX + horizontalPadding,
        y: CGFloat(height) - toastRect.midY - toastFont.pointSize / 2 - 2,
        color: foreground,
        using: toastFont
    )
}

for frame in 0..<frameCount {
    let playbackTime = Double(frame) / framesPerSecond
    let time = playbackTime * playbackSpeed
    let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: width,
        pixelsHigh: height,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 32
    )!

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    NSColor(calibratedRed: 0.055, green: 0.067, blue: 0.086, alpha: 1).setFill()
    NSBezierPath(rect: NSRect(x: 0, y: 0, width: width, height: height)).fill()

    NSColor(calibratedRed: 0.09, green: 0.11, blue: 0.14, alpha: 1).setFill()
    NSBezierPath(rect: NSRect(x: 0, y: CGFloat(height) - titleBarHeight, width: CGFloat(width), height: titleBarHeight)).fill()

    let windowControls: [(CGFloat, NSColor)] = [
        (26, .systemRed),
        (48, .systemYellow),
        (70, .systemGreen),
    ]
    let windowControlY = CGFloat(height) - (titleBarHeight + windowControlSize) / 2
    for (x, color) in windowControls {
        color.setFill()
        NSBezierPath(ovalIn: NSRect(x: x, y: windowControlY, width: windowControlSize, height: windowControlSize)).fill()
    }
    let left: CGFloat = 42
    if time >= 0.7 {
        draw("❯", x: left, y: 90, color: green)
        draw(typed("pwd", from: 0.85, at: time), x: left + 34, y: 90, color: foreground)
    }
    if time >= 1.35 {
        draw("/Users/me/src/fish-copypath", x: left, y: 130, color: blue)
    }
    if time >= 2.0 {
        draw("❯", x: left, y: 190, color: green)
        draw(typed("copypath README.md", from: 2.15, at: time), x: left + 34, y: 190, color: foreground)
    }
    if time >= 3.55 {
        draw("Copied: /Users/me/src/fish-copypath/README.md", x: left, y: 230, color: foreground)
    }
    if time >= 4.35 {
        draw("❯", x: left, y: 290, color: green)
    }
    if time >= 4.35 && time < 8.5 {
        drawToast("Paste from clipboard")
    }
    if time >= 4.75 {
        draw("/Users/me/src/fish-copypath/README.md", x: left + 34, y: 290, color: blue)
    }
    if time >= 6.0 {
        draw("❯", x: left, y: 390, color: green)
        if Int(playbackTime * 2).isMultiple(of: 2) {
            NSColor(calibratedRed: 0.72, green: 0.76, blue: 0.80, alpha: 1).setFill()
            NSBezierPath(rect: NSRect(x: left + 34, y: CGFloat(height - 415), width: 13, height: 25)).fill()
        }
    }

    NSGraphicsContext.restoreGraphicsState()
    CGImageDestinationAddImage(destination, bitmap.cgImage!, [
        kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: 1.0 / framesPerSecond]
    ] as CFDictionary)
}

guard CGImageDestinationFinalize(destination) else {
    fatalError("Failed to write GIF to \(outputURL.path)")
}
