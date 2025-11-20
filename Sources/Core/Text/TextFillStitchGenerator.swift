import Foundation
import CoreGraphics

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
    func generateFillStitches(
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
            let fillStitches = generateFillForPath(
                path: glyphPath.path,
                bounds: glyphPath.bounds,
                density: density,
                angle: fillAngle
            )

            // Skip if no stitches
            guard !fillStitches.isEmpty else { continue }

            // Create a stitch group for this character fill
            let stitchGroup = StitchGroup(
                id: UUID(),
                type: .satin,
                points: fillStitches,
                color: color,
                density: density
            )

            stitchGroups.append(stitchGroup)
        }

        return stitchGroups
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
    /// Uses scanline algorithm to fill path interior with parallel lines
    private func generateFillForPath(
        path: CGPath,
        bounds: CGRect,
        density: Double,
        angle: Double
    ) -> [StitchPoint] {
        var stitchPoints: [StitchPoint] = []

        // Calculate line spacing based on density
        // For satin fill, lines should be closer together
        let lineSpacing = 1.0 / (density * 1.5) // mm between fill lines

        // Convert angle to radians
        let angleRad = angle * .pi / 180.0

        // Calculate the perpendicular direction for scanlines
        let perpAngle = angleRad + .pi / 2

        // Determine scanning bounds
        // We need to scan the bounding box rotated by the fill angle
        let expandedBounds = bounds.insetBy(dx: -10, dy: -10)

        // Calculate scanline extents
        let scanLength = sqrt(
            expandedBounds.width * expandedBounds.width +
            expandedBounds.height * expandedBounds.height
        )

        // Calculate number of scanlines needed
        let numLines = Int(ceil(scanLength / lineSpacing))

        // Generate scanlines
        for i in 0..<numLines {
            let offset = Double(i) * lineSpacing - scanLength / 2

            // Calculate scanline start and end points
            let centerX = expandedBounds.midX
            let centerY = expandedBounds.midY

            // Start point (one end of the scanline)
            let startX = centerX + CGFloat(cos(perpAngle) * offset - sin(perpAngle) * scanLength / 2)
            let startY = centerY + CGFloat(sin(perpAngle) * offset + cos(perpAngle) * scanLength / 2)

            // End point (other end of the scanline)
            let endX = centerX + CGFloat(cos(perpAngle) * offset + sin(perpAngle) * scanLength / 2)
            let endY = centerY + CGFloat(sin(perpAngle) * offset - cos(perpAngle) * scanLength / 2)

            let startPoint = CGPoint(x: startX, y: startY)
            let endPoint = CGPoint(x: endX, y: endY)

            // Find intersections of this line with the path
            let intersections = findLinePathIntersections(
                lineStart: startPoint,
                lineEnd: endPoint,
                path: path
            )

            // Convert intersections to stitch segments
            // Intersections should be paired (entry/exit)
            if intersections.count >= 2 {
                // Sort by distance from start
                let sortedIntersections = intersections.sorted { i1, i2 in
                    let d1 = distance(startPoint, i1)
                    let d2 = distance(startPoint, i2)
                    return d1 < d2
                }

                // Pair up intersections (entry/exit pairs)
                for j in stride(from: 0, to: sortedIntersections.count - 1, by: 2) {
                    let entry = sortedIntersections[j]
                    let exit = sortedIntersections[j + 1]

                    // Add stitch segment
                    stitchPoints.append(StitchPoint(x: Double(entry.x), y: Double(entry.y)))
                    stitchPoints.append(StitchPoint(x: Double(exit.x), y: Double(exit.y)))
                }
            }
        }

        return stitchPoints
    }

    /// Find intersections between a line segment and a path
    /// This is a simplified version that samples the line and tests if points are inside the path
    private func findLinePathIntersections(
        lineStart: CGPoint,
        lineEnd: CGPoint,
        path: CGPath
    ) -> [CGPoint] {
        var intersections: [CGPoint] = []

        // Sample the line at fine intervals
        let samples = 200
        var wasInside = false

        for i in 0...samples {
            let t = CGFloat(i) / CGFloat(samples)
            let point = CGPoint(
                x: lineStart.x + (lineEnd.x - lineStart.x) * t,
                y: lineStart.y + (lineEnd.y - lineStart.y) * t
            )

            let isInside = path.contains(point, using: .winding)

            // Detect transitions (entry/exit)
            if i > 0 && isInside != wasInside {
                intersections.append(point)
            }

            wasInside = isInside
        }

        return intersections
    }

    /// Calculate distance between two points
    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        return sqrt(dx * dx + dy * dy)
    }
}
