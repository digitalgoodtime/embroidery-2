import Foundation
import CoreGraphics
import AppKit

/// Generates fill stitches for text characters using satin stitch technique
class TextFillStitchGenerator {

    private let pathGenerator = TextPathGenerator()

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
            // Use the SAME approach as outline - sample the path into boundary points
            let subpaths = pathGenerator.samplePathBySubpath(glyphPath.path, density: 2.0)

            // Generate fill for this glyph using the sampled boundary
            let fillStitchGroups = generateFillFromBoundary(
                subpaths: subpaths,
                bounds: glyphPath.bounds,
                density: textObject.effectiveDensity(),
                color: fillColor
            )

            stitchGroups.append(contentsOf: fillStitchGroups)
        }

        return stitchGroups
    }

    /// Generate fill using the already-sampled boundary points from path
    private func generateFillFromBoundary(
        subpaths: [[CGPoint]],
        bounds: CGRect,
        density: Double,
        color: CodableColor
    ) -> [StitchGroup] {
        guard !subpaths.isEmpty else { return [] }

        // Collect all boundary edges from all subpaths
        var allEdges: [(CGPoint, CGPoint)] = []

        for subpath in subpaths {
            // Create edges between consecutive points
            for i in 0..<subpath.count - 1 {
                allEdges.append((subpath[i], subpath[i + 1]))
            }
            // Close the subpath
            if let first = subpath.first, let last = subpath.last, first != last {
                allEdges.append((last, first))
            }
        }

        guard !allEdges.isEmpty else { return [] }

        // Line spacing based on density
        let lineSpacing = 1.0 / (density * 1.5)

        var allStitchPoints: [StitchPoint] = []

        // Generate horizontal scanlines
        var y = bounds.minY
        var scanlineIndex = 0

        while y <= bounds.maxY {
            // Find intersections with all edges at this Y
            var xIntersections: [CGFloat] = []

            for (p1, p2) in allEdges {
                let y1 = p1.y
                let y2 = p2.y

                // Check if edge crosses this Y
                let minY = min(y1, y2)
                let maxY = max(y1, y2)

                if y >= minY && y <= maxY && abs(y2 - y1) > 0.0001 {
                    // Calculate X at intersection
                    let t = (y - y1) / (y2 - y1)
                    let x = p1.x + t * (p2.x - p1.x)
                    xIntersections.append(x)
                }
            }

            // Sort intersections
            xIntersections.sort()

            // Create fill segments from pairs
            if xIntersections.count >= 2 {
                for i in stride(from: 0, to: xIntersections.count - 1, by: 2) {
                    let x1 = xIntersections[i]
                    let x2 = xIntersections[i + 1]

                    // Zigzag pattern
                    if scanlineIndex % 2 == 0 {
                        allStitchPoints.append(StitchPoint(x: Double(x1), y: Double(y)))
                        allStitchPoints.append(StitchPoint(x: Double(x2), y: Double(y)))
                    } else {
                        allStitchPoints.append(StitchPoint(x: Double(x2), y: Double(y)))
                        allStitchPoints.append(StitchPoint(x: Double(x1), y: Double(y)))
                    }
                }
            }

            y += CGFloat(lineSpacing)
            scanlineIndex += 1
        }

        guard !allStitchPoints.isEmpty else { return [] }

        // Split into groups at large gaps
        var groups: [StitchGroup] = []
        var currentGroup: [StitchPoint] = []
        let maxJumpDistance = 5.0

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
}
