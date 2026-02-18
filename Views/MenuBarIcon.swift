import AppKit

enum MenuBarIcon {
    static func create(size: CGFloat = 18) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            let center = CGPoint(x: size / 2, y: size / 2)
            let half = size / 2

            // Ring
            let ringMidRadius = half * 0.82
            let ringWidth = half * 0.22
            let ringPath = NSBezierPath(ovalIn: NSRect(
                x: center.x - ringMidRadius,
                y: center.y - ringMidRadius,
                width: ringMidRadius * 2,
                height: ringMidRadius * 2
            ))
            ringPath.lineWidth = ringWidth
            NSColor.black.setStroke()
            ringPath.stroke()

            // Needle (rounded rectangle at ~11 o'clock)
            let needleAngle: CGFloat = 120 * .pi / 180
            let needleDist = half * 0.35
            let needleLength = half * 0.42
            let needleWidth = half * 0.16
            let needleCornerRadius = needleWidth / 2

            let needleCenterX = center.x + needleDist * cos(needleAngle)
            let needleCenterY = center.y + needleDist * sin(needleAngle)

            let transform = NSAffineTransform()
            transform.translateX(by: needleCenterX, yBy: needleCenterY)
            transform.rotate(byRadians: needleAngle - .pi / 2)

            NSGraphicsContext.current?.saveGraphicsState()
            transform.concat()

            let needleRect = NSRect(
                x: -needleWidth / 2,
                y: -needleLength / 2,
                width: needleWidth,
                height: needleLength
            )
            let needlePath = NSBezierPath(roundedRect: needleRect, xRadius: needleCornerRadius, yRadius: needleCornerRadius)
            NSColor.black.setFill()
            needlePath.fill()

            NSGraphicsContext.current?.restoreGraphicsState()

            return true
        }
        image.isTemplate = true
        return image
    }
}
