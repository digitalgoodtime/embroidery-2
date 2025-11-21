import Foundation
import CoreGraphics
import AppKit

/// Generates fill stitches for text characters using satin stitch technique
class TextFillStitchGenerator {

    private let pathGenerator = TextPathGenerator()

    /// Fill angle in degrees (45° is typical for text)
    private let fillAngle: Double = 45.0

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

        // Generate paths for text
        let pathResult = pathGenerator.generatePaths(
            for: textObject.text,
            font: font,
            at: textObject.position,
            letterSpacing: CGFloat(textObject.letterSpacing),
            alignment: textObject.alignment
        )

        var stitchGroups: [StitchGroup] = []

        // Process each glyph path
        for glyphPath in pathResult.glyphPaths {
            // Generate fill for this glyph
            let fillStitchGroups = generateFillForGlyph(
                path: glyphPath.path,
                bounds: glyphPath.bounds,
                density: textObject.effectiveDensity(),
                color: fillColor
            )

            stitchGroups.append(contentsOf: fillStitchGroups)
        }

        return stitchGroups
    }

    /// Generate fill stitch groups for a single glyph
    private func generateFillForGlyph(
        path: CGPath,
        bounds: CGRect,
        density: Double,
        color: CodableColor
    ) -> [StitchGroup] {
        // Line spacing based on density
        let lineSpacing = 1.0 / (density * 1.5) // mm between fill lines

        // Start with simple horizontal scanlines to verify the approach works
        // TODO: Add angle support once horizontal works

        var allStitchPoints: [StitchPoint] = []

        // Expand bounds slightly
        let expandedBounds = bounds.insetBy(dx: -2, dy: -2)

        // Generate horizontal scanlines from top to bottom
        var y = expandedBounds.minY
        var scanlineIndex = 0

        while y <= expandedBounds.maxY {
            // Create horizontal line across the entire width
            let lineStart = CGPoint(x: expandedBounds.minX - 10, y: y)
            let lineEnd = CGPoint(x: expandedBounds.maxX + 10, y: y)

            // Find all intersections with the path
            let intersections = findPathIntersections(
                lineStart: lineStart,
                lineEnd: lineEnd,
                path: path
            )

            // Create stitch segments from intersection pairs
            // Pairs represent entry/exit points
            if intersections.count >= 2 {
                for i in stride(from: 0, to: intersections.count - 1, by: 2) {
                    let entry = intersections[i]
                    let exit = intersections[i + 1]

                    // Zigzag: reverse every other line
                    if scanlineIndex % 2 == 0 {
                        allStitchPoints.append(StitchPoint(x: Double(entry.x), y: Double(entry.y)))
                        allStitchPoints.append(StitchPoint(x: Double(exit.x), y: Double(exit.y)))
                    } else {
                        allStitchPoints.append(StitchPoint(x: Double(exit.x), y: Double(exit.y)))
                        allStitchPoints.append(StitchPoint(x: Double(entry.x), y: Double(entry.y)))
                    }
                }
            }

            y += CGFloat(lineSpacing)
            scanlineIndex += 1
        }

        guard !allStitchPoints.isEmpty else { return [] }

        // Split into groups at large gaps (for holes/discontinuities)
        var groups: [StitchGroup] = []
        var currentGroup: [StitchPoint] = []
        let maxJumpDistance = 5.0  // mm

        for i in 0..<allStitchPoints.count {
            let stitch = allStitchPoints[i]

            if i > 0 {
                let prevStitch = allStitchPoints[i - 1]
                let dx = stitch.x - prevStitch.x
                let dy = stitch.y - prevStitch.y
                let distance = sqrt(dx * dx + dy * dy)

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

    /// Find all intersections between a line and a path
    /// Returns points sorted along the line
    private func findPathIntersections(
        lineStart: CGPoint,
        lineEnd: CGPoint,
        path: CGPath
    ) -> [CGPoint] {
        var intersections: [CGPoint] = []

        // Calculate line length
        let dx = lineEnd.x - lineStart.x
        let dy = lineEnd.y - lineStart.y
        let lineLength = sqrt(dx * dx + dy * dy)

        // Sample at very fine intervals (0.1mm steps)
        let sampleStep = 0.1
        let numSamples = Int(ceil(Double(lineLength) / sampleStep))

        guard numSamples > 0 else { return [] }

        var wasInside = false

        for i in 0...numSamples {
            let t = CGFloat(i) / CGFloat(numSamples)
            let point = CGPoint(
                x: lineStart.x + dx * t,
                y: lineStart.y + dy * t
            )

            // Check if point is inside the path
            // Try winding rule instead of evenOdd
            let isInside = path.contains(point, using: .winding)

            // Detect boundary crossing
            if i > 0 && isInside != wasInside {
                // Found an intersection
                intersections.append(point)
            }

            wasInside = isInside
        }

        return intersections
    }
}
