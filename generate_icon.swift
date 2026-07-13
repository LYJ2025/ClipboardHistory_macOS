import AppKit
import CoreGraphics

let size = CGSize(width: 1024, height: 1024)
let image = NSImage(size: size)

image.lockFocus()

let context = NSGraphicsContext.current!.cgContext

// Background rounded rect
let cornerRadius: CGFloat = 180
let rect = CGRect(origin: .zero, size: size)
let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
path.addClip()

// Gradient background
let colorSpace = CGColorSpaceCreateDeviceRGB()
let gradient = CGGradient(colorsSpace: colorSpace,
                          colors: [NSColor(red: 0.72, green: 0.88, blue: 1.0, alpha: 1.0).cgColor,
                                   NSColor(red: 0.52, green: 0.76, blue: 1.0, alpha: 1.0).cgColor] as CFArray,
                          locations: [0.0, 1.0])!
context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: size.height), end: CGPoint(x: 0, y: 0), options: [])

// Clipboard body
let clipboardWidth: CGFloat = 520
let clipboardHeight: CGFloat = 620
let clipboardX = (size.width - clipboardWidth) / 2
let clipboardY = (size.height - clipboardHeight) / 2 + 20
let clipboardRect = CGRect(x: clipboardX, y: clipboardY, width: clipboardWidth, height: clipboardHeight)
let clipboardPath = NSBezierPath(roundedRect: clipboardRect, xRadius: 50, yRadius: 50)
NSColor.white.setFill()
clipboardPath.fill()

// Clipboard clip
let clipWidth: CGFloat = 220
let clipHeight: CGFloat = 90
let clipX = (size.width - clipWidth) / 2
let clipY = clipboardY + clipboardHeight - clipHeight / 2
let clipRect = CGRect(x: clipX, y: clipY, width: clipWidth, height: clipHeight)
let clipPath = NSBezierPath(roundedRect: clipRect, xRadius: 25, yRadius: 25)
NSColor(red: 0.72, green: 0.88, blue: 1.0, alpha: 1.0).setFill()
clipPath.fill()

// Lines on clipboard
let lineCount = 4
let lineSpacing: CGFloat = 80
let lineYStart = clipboardY + 140
let lineWidth: CGFloat = 380
let lineHeight: CGFloat = 24
let lineX = (size.width - lineWidth) / 2

for i in 0..<lineCount {
    let lineRect = CGRect(x: lineX, y: lineYStart + CGFloat(i) * lineSpacing, width: lineWidth, height: lineHeight)
    let linePath = NSBezierPath(roundedRect: lineRect, xRadius: 12, yRadius: 12)
    NSColor(red: 0.82, green: 0.92, blue: 1.0, alpha: 1.0).setFill()
    linePath.fill()
}

image.unlockFocus()

// Save as PNG
if let tiffData = image.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiffData),
   let pngData = bitmap.representation(using: .png, properties: [:]) {
    let url = URL(fileURLWithPath: "icon.png")
    try? pngData.write(to: url)
    print("Icon saved to icon.png")
}
