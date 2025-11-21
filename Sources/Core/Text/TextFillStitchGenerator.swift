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

        // First, extract all edges from the path
        let edges = extractEdges(from: path)

        guard !edges.isEmpty else { return [] }

        var allStitchPoints: [StitchPoint] = []

        // Expand bounds slightly
        let expandedBounds = bounds.insetBy(dx: -2, dy: -2)

        // Generate horizontal scanlines from top to bottom
        var y = expandedBounds.minY
        var scanlineIndex = 0

        while y <= expandedBounds.maxY {
            // Find all intersections with edges at this Y coordinate
            var xIntersections: [CGFloat] = []

            for edge in edges {
                if let x = findHorizontalIntersection(edge: edge, atY: y) {
                    xIntersections.append(x)
                }
            }

            // Sort intersections by X coordinate
            xIntersections.sort()

            // Create stitch segments from pairs (entry/exit)
            if xIntersections.count >= 2 {
                for i in stride(from: 0, to: xIntersections.count - 1, by: 2) {
                    let x1 = xIntersections[i]
                    let x2 = xIntersections[i + 1]

                    // Zigzag: reverse every other line
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

    /// Represents an edge (line segment) in the path
    private struct Edge {
        let p1: CGPoint
        let p2: CGPoint
    }

    /// Extract all edges from a CGPath by walking its elements
    /// Similar to how outline code walks the path
    private func extractEdges(from path: CGPath) -> [Edge] {
        var edges: [Edge] = []
        var currentPoint: CGPoint?
        var subpathStart: CGPoint?

        path.applyWithBlock { element in
            let elementType = element.pointee.type
            let points = element.pointee.points

            switch elementType {
            case .moveToPoint:
                let point = points[0]
                currentPoint = point
                subpathStart = point

            case .addLineToPoint:
                let point = points[0]
                if let start = currentPoint {
                    edges.append(Edge(p1: start, p2: point))
                }
                currentPoint = point

            case .addQuadCurveToPoint:
                // Flatten quadratic curve into line segments
                let control = points[0]
                let end = points[1]
                if let start = currentPoint {
                    let segments = flattenQuadraticCurve(start: start, control: control, end: end)
                    edges.append(contentsOf: segments)
                }
                currentPoint = end

            case .addCurveToPoint:
                // Flatten cubic curve into line segments
                let control1 = points[0]
                let control2 = points[1]
                let end = points[2]
                if let start = currentPoint {
                    let segments = flattenCubicCurve(start: start, control1: control1, control2: control2, end: end)
                    edges.append(contentsOf: segments)
                }
                currentPoint = end

            case .closeSubpath:
                // Add edge back to subpath start
                if let start = subpathStart, let current = currentPoint, start != current {
                    edges.append(Edge(p1: current, p2: start))
                }
                currentPoint = subpathStart

            @unknown default:
                break
            }
        }

        return edges
    }

    /// Flatten quadratic bezier curve into line segments
    private func flattenQuadraticCurve(start: CGPoint, control: CGPoint, end: CGPoint) -> [Edge] {
        var edges: [Edge] = []
        let numSegments = 10

        var previousPoint = start
        for i in 1...numSegments {
            let t = CGFloat(i) / CGFloat(numSegments)
            let t2 = 1 - t

            let x = t2 * t2 * start.x + 2 * t2 * t * control.x + t * t * end.x
            let y = t2 * t2 * start.y + 2 * t2 * t * control.y + t * t * end.y
            let point = CGPoint(x: x, y: y)

            edges.append(Edge(p1: previousPoint, p2: point))
            previousPoint = point
        }

        return edges
    }

    /// Flatten cubic bezier curve into line segments
    private func flattenCubicCurve(start: CGPoint, control1: CGPoint, control2: CGPoint, end: CGPoint) -> [Edge] {
        var edges: [Edge] = []
        let numSegments = 10

        var previousPoint = start
        for i in 1...numSegments {
            let t = CGFloat(i) / CGFloat(numSegments)
            let t2 = 1 - t

            let x = t2 * t2 * t2 * start.x +
                    3 * t2 * t2 * t * control1.x +
                    3 * t2 * t * t * control2.x +
                    t * t * t * end.x
            let y = t2 * t2 * t2 * start.y +
                    3 * t2 * t2 * t * control1.y +
                    3 * t2 * t * t * control2.y +
                    t * t * t * end.y
            let point = CGPoint(x: x, y: y)

            edges.append(Edge(p1: previousPoint, p2: point))
            previousPoint = point
        }

        return edges
    }

    /// Find where a horizontal line at Y intersects an edge
    /// Returns the X coordinate of intersection, or nil if no intersection
    private func findHorizontalIntersection(edge: Edge, atY y: CGFloat) -> CGFloat? {
        let y1 = edge.p1.y
        let y2 = edge.p2.y

        // Check if edge crosses this Y coordinate
        let minY = min(y1, y2)
        let maxY = max(y1, y2)

        guard y >= minY && y <= maxY else {
            return nil
        }

        // Handle horizontal edges (parallel to scanline)
        if abs(y2 - y1) < 0.0001 {
            return nil
        }

        // Calculate X coordinate of intersection using linear interpolation
        let t = (y - y1) / (y2 - y1)
        let x = edge.p1.x + t * (edge.p2.x - edge.p1.x)

        return x
    }
}
