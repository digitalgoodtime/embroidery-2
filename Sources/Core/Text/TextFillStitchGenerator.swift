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
    /// Uses scanline algorithm to fill path interior with parallel lines
    private func generateFillForPath(
        path: CGPath,
        bounds: CGRect,
        density: Double,
        angle: Double
    ) -> [StitchPoint] {
        // Calculate line spacing based on density
        // For satin fill, lines should be closer together
        let lineSpacing = 1.0 / (density * 1.5) // mm between fill lines

        // Expand bounds slightly to ensure complete coverage
        let expandedBounds = bounds.insetBy(dx: -5, dy: -5)

        // Use rotation-based approach for clarity and correctness
        // Strategy: rotate coordinate system so fill lines become horizontal,
        // generate horizontal scanlines, then rotate results back

        // Negate angle because Y-axis is flipped (Y increases downward)
        let fillAngleRad = -angle * .pi / 180.0

        // Create rotation transform (rotate by -fillAngle to make fill lines horizontal)
        let rotateToHorizontal = CGAffineTransform(rotationAngle: -fillAngleRad)
        let rotateBack = CGAffineTransform(rotationAngle: fillAngleRad)

        // Rotate the path and bounds to align fill direction with horizontal
        let rotatedPath = path.copy(using: &rotateToHorizontal.unsafelyUnwrapped)!
        let rotatedBounds = expandedBounds.applying(rotateToHorizontal)

        // Generate horizontal scanlines in rotated space
        let minY = rotatedBounds.minY
        let maxY = rotatedBounds.maxY
        let scanlineWidth = rotatedBounds.width * 2 // Make sure scanlines are long enough

        var scanlineSegments: [[CGPoint]] = []
        var y = minY
        var scanlineIndex = 0

        while y <= maxY {
            // Create horizontal scanline at this Y
            let scanlineStart = CGPoint(x: rotatedBounds.midX - scanlineWidth, y: y)
            let scanlineEnd = CGPoint(x: rotatedBounds.midX + scanlineWidth, y: y)

            // Find intersections with the rotated path
            let intersections = findLinePathIntersections(
                lineStart: scanlineStart,
                lineEnd: scanlineEnd,
                path: rotatedPath
            )

            // Pair up intersections (entry/exit)
            if intersections.count >= 2 {
                // Sort by X coordinate
                let sortedIntersections = intersections.sorted { $0.x < $1.x }

                // Process pairs
                for j in stride(from: 0, to: sortedIntersections.count - 1, by: 2) {
                    var entry = sortedIntersections[j]
                    var exit = sortedIntersections[j + 1]

                    // Rotate points back to original coordinate system
                    entry = entry.applying(rotateBack)
                    exit = exit.applying(rotateBack)

                    // For satin stitch zigzag: reverse direction on alternate scanlines
                    if scanlineIndex % 2 == 0 {
                        scanlineSegments.append([entry, exit])
                    } else {
                        scanlineSegments.append([exit, entry])
                    }
                }
            }

            y += lineSpacing
            scanlineIndex += 1
        }

        // Connect segments into continuous stitch path
        var stitchPoints: [StitchPoint] = []
        for segment in scanlineSegments {
            for point in segment {
                stitchPoints.append(StitchPoint(x: Double(point.x), y: Double(point.y)))
            }
        }

        return stitchPoints
    }

    /// Find intersections between a line segment and a path
    /// Uses sampling with binary search refinement for precise boundary detection
    private func findLinePathIntersections(
        lineStart: CGPoint,
        lineEnd: CGPoint,
        path: CGPath
    ) -> [CGPoint] {
        var intersections: [CGPoint] = []

        // Sample the line at fine intervals
        let samples = 400 // Increased for better precision
        var wasInside = false
        var prevT: CGFloat = 0
        var prevPoint = lineStart

        for i in 0...samples {
            let t = CGFloat(i) / CGFloat(samples)
            let point = CGPoint(
                x: lineStart.x + (lineEnd.x - lineStart.x) * t,
                y: lineStart.y + (lineEnd.y - lineStart.y) * t
            )

            // Use evenOdd rule because path has been Y-flipped, which reverses winding
            let isInside = path.contains(point, using: .evenOdd)

            // Detect transitions (entry/exit)
            if i > 0 && isInside != wasInside {
                // Binary search to refine the intersection point
                let refinedPoint = refineIntersection(
                    lineStart: lineStart,
                    lineEnd: lineEnd,
                    path: path,
                    t1: prevT,
                    t2: t,
                    wasInside: wasInside
                )
                intersections.append(refinedPoint)
            }

            wasInside = isInside
            prevT = t
            prevPoint = point
        }

        return intersections
    }

    /// Refine intersection point using binary search
    private func refineIntersection(
        lineStart: CGPoint,
        lineEnd: CGPoint,
        path: CGPath,
        t1: CGFloat,
        t2: CGFloat,
        wasInside: Bool
    ) -> CGPoint {
        var tMin = t1
        var tMax = t2

        // Binary search for precise intersection (10 iterations gives ~0.1% precision)
        for _ in 0..<10 {
            let tMid = (tMin + tMax) / 2
            let midPoint = CGPoint(
                x: lineStart.x + (lineEnd.x - lineStart.x) * tMid,
                y: lineStart.y + (lineEnd.y - lineStart.y) * tMid
            )

            // Use evenOdd rule because path has been Y-flipped, which reverses winding
            let isInside = path.contains(midPoint, using: .evenOdd)

            if isInside == wasInside {
                tMin = tMid
            } else {
                tMax = tMid
            }
        }

        // Use the point just inside the boundary
        // If wasInside: we're exiting, so use tMin (last inside point)
        // If !wasInside: we're entering, so use tMax (first inside point)
        let finalT = wasInside ? tMin : tMax
        return CGPoint(
            x: lineStart.x + (lineEnd.x - lineStart.x) * finalT,
            y: lineStart.y + (lineEnd.y - lineStart.y) * finalT
        )
    }

    /// Calculate distance between two points
    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        return sqrt(dx * dx + dy * dy)
    }
}
