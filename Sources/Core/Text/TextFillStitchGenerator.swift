import Foundation
import CoreGraphics
import AppKit

/// Generates fill stitches for text characters using satin stitch technique
class TextFillStitchGenerator {

    private let pathGenerator = TextPathGenerator()

    /// Fill angle in degrees (45° is typical for text)
    private let fillAngle: Double = 45.0

    /// Generate fill stitches for text
    /// - Parameters:
    ///   - text: Text content
    ///   - font: NSFont to use
    ///   - position: Starting position
    ///   - density: Stitch density in stitches per mm
    ///   - color: Thread color
    ///   - letterSpacing: Additional letter spacing
    ///   - alignment: Text alignment
    /// - Returns: Array of StitchGroups representing the fill
    private func generateFillStitches(
        text: String,
        font: NSFont,
        position: CGPoint,
        density: Double,
        color: CodableColor,
        letterSpacing: Double = 0,
        alignment: TextObject.TextAlignment = .left
    ) -> [StitchGroup] {
        // Generate paths for text
        let pathResult = pathGenerator.generatePaths(
            for: text,
            font: font,
            at: position,
            letterSpacing: CGFloat(letterSpacing),
            alignment: alignment
        )

        var stitchGroups: [StitchGroup] = []

        // Process each glyph path
        for glyphPath in pathResult.glyphPaths {
            // Generate fill lines for this glyph
            let fillStitchGroups = generateFillGroupsForPath(
                path: glyphPath.path,
                bounds: glyphPath.bounds,
                density: density,
                angle: fillAngle,
                color: color
            )

            stitchGroups.append(contentsOf: fillStitchGroups)
        }

        return stitchGroups
    }

    /// Generate fill stitch groups for a path, splitting into multiple groups for discontinuities
    private func generateFillGroupsForPath(
        path: CGPath,
        bounds: CGRect,
        density: Double,
        angle: Double,
        color: CodableColor
    ) -> [StitchGroup] {
        let allStitches = generateFillForPath(
            path: path,
            bounds: bounds,
            density: density,
            angle: angle
        )

        guard !allStitches.isEmpty else { return [] }

        // Split into groups at large gaps (holes)
        var groups: [StitchGroup] = []
        var currentGroup: [StitchPoint] = []
        let maxJumpDistance = 5.0  // mm

        for i in 0..<allStitches.count {
            let stitch = allStitches[i]

            if i > 0 {
                let prevStitch = allStitches[i - 1]
                let dx = stitch.x - prevStitch.x
                let dy = stitch.y - prevStitch.y
                let distance = sqrt(dx * dx + dy * dy)

                // If large gap, start new group
                if distance > maxJumpDistance {
                    if !currentGroup.isEmpty {
                        groups.append(StitchGroup(
                            id: UUID(),
                            type: .satin,
                            points: currentGroup,
                            color: color,
                            density: density
                        ))
                        currentGroup = []
                    }
                }
            }

            currentGroup.append(stitch)
        }

        // Add final group
        if !currentGroup.isEmpty {
            groups.append(StitchGroup(
                id: UUID(),
                type: .satin,
                points: currentGroup,
                color: color,
                density: density
            ))
        }

        return groups
    }

    /// Generate fill stitches from a TextObject
    /// - Parameter textObject: The text object to generate stitches for
    /// - Returns: Array of StitchGroups
    func generateFillStitches(for textObject: TextObject) -> [StitchGroup] {
        // Get the font
        guard let embroideryFont = EmbroideryFontManager.shared.font(named: textObject.fontName),
              let fillColor = textObject.fillColor else {
            return []
        }

        // Convert font size from mm to points
        let pointSize = TextPathGenerator.mmToPoints(textObject.fontSize)
        let font = embroideryFont.nsFont.withSize(pointSize)

        return generateFillStitches(
            text: textObject.text,
            font: font,
            position: textObject.position,
            density: textObject.effectiveDensity(),
            color: fillColor,
            letterSpacing: textObject.letterSpacing,
            alignment: textObject.alignment
        )
    }

    /// Generate fill stitches for a single character path
    /// Uses scanline algorithm - generates lines perpendicular to fill angle
    private func generateFillForPath(
        path: CGPath,
        bounds: CGRect,
        density: Double,
        angle: Double
    ) -> [StitchPoint] {
        // Line spacing based on density
        let lineSpacing = 1.0 / (density * 1.5) // mm between fill lines

        // Expand bounds to ensure coverage
        let expandedBounds = bounds.insetBy(dx: -5, dy: -5)

        // Convert angle to radians
        // Negate because Y-axis is flipped (Y increases downward in canvas coordinates)
        let fillAngleRad = -angle * .pi / 180.0

        // Scanlines are perpendicular to fill direction
        let scanlineAngleRad = fillAngleRad + .pi / 2

        // Calculate how far we need to step perpendicular to cover the bounds
        // Use diagonal length to ensure complete coverage
        let diagonal = sqrt(
            expandedBounds.width * expandedBounds.width +
            expandedBounds.height * expandedBounds.height
        )

        // Calculate number of scanlines needed
        let numScanlines = Int(ceil(Double(diagonal) / lineSpacing))

        // Center point to generate scanlines around
        let centerX = expandedBounds.midX
        let centerY = expandedBounds.midY

        var scanlineSegments: [[CGPoint]] = []

        // Generate each scanline
        for i in 0..<numScanlines {
            // Calculate offset from center (perpendicular to fill direction)
            let offset = (Double(i) - Double(numScanlines) / 2.0) * lineSpacing

            // Position along perpendicular direction
            let scanlineOriginX = centerX + CGFloat(cos(scanlineAngleRad) * offset)
            let scanlineOriginY = centerY + CGFloat(sin(scanlineAngleRad) * offset)

            // Extend scanline in fill direction (long enough to cross entire bounds)
            let halfLength = diagonal
            let startX = scanlineOriginX - CGFloat(cos(fillAngleRad) * halfLength)
            let startY = scanlineOriginY - CGFloat(sin(fillAngleRad) * halfLength)
            let endX = scanlineOriginX + CGFloat(cos(fillAngleRad) * halfLength)
            let endY = scanlineOriginY + CGFloat(sin(fillAngleRad) * halfLength)

            let scanlineStart = CGPoint(x: startX, y: startY)
            let scanlineEnd = CGPoint(x: endX, y: endY)

            // Find where this scanline intersects the path
            let intersections = findIntersections(
                lineStart: scanlineStart,
                lineEnd: scanlineEnd,
                path: path
            )

            // Pair up intersections (entry/exit) and create segments
            if intersections.count >= 2 {
                // Process pairs
                for j in stride(from: 0, to: intersections.count - 1, by: 2) {
                    let entry = intersections[j]
                    let exit = intersections[j + 1]

                    // Zigzag pattern: reverse direction on alternate scanlines
                    if i % 2 == 0 {
                        scanlineSegments.append([entry, exit])
                    } else {
                        scanlineSegments.append([exit, entry])
                    }
                }
            }
        }

        // Convert to stitch points
        var stitchPoints: [StitchPoint] = []
        for segment in scanlineSegments {
            for point in segment {
                stitchPoints.append(StitchPoint(x: Double(point.x), y: Double(point.y)))
            }
        }

        return stitchPoints
    }

    /// Find intersections between a line and a path by sampling
    /// Returns sorted intersection points along the line
    private func findIntersections(
        lineStart: CGPoint,
        lineEnd: CGPoint,
        path: CGPath
    ) -> [CGPoint] {
        var intersections: [CGPoint] = []

        // Sample along the line
        let numSamples = 500
        var wasInside = false

        for i in 0...numSamples {
            let t = CGFloat(i) / CGFloat(numSamples)
            let point = CGPoint(
                x: lineStart.x + (lineEnd.x - lineStart.x) * t,
                y: lineStart.y + (lineEnd.y - lineStart.y) * t
            )

            // Use evenOdd fill rule (path is Y-flipped)
            let isInside = path.contains(point, using: .evenOdd)

            // Detect transition (crossing boundary)
            if i > 0 && isInside != wasInside {
                intersections.append(point)
            }

            wasInside = isInside
        }

        return intersections
    }
}
