import Foundation
import CoreGraphics
import AppKit

/// Generates outline stitches for text by tracing character paths
class TextOutlineStitchGenerator {

    private let pathGenerator = TextPathGenerator()

    /// Generate outline stitches for text
    /// - Parameters:
    ///   - text: Text content
    ///   - font: NSFont to use
    ///   - position: Starting position
    ///   - density: Stitch density in stitches per mm
    ///   - color: Thread color
    ///   - letterSpacing: Additional letter spacing
    ///   - alignment: Text alignment
    /// - Returns: Array of StitchGroups representing the outline
    private func generateOutlineStitches(
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
            // Sample points along the path
            let sampledPoints = pathGenerator.samplePath(glyphPath.path, density: density)

            // Skip if no points
            guard !sampledPoints.isEmpty else { continue }

            // Split into separate groups at moveToPoint (new subpaths)
            // This prevents drawing lines between outer boundary and holes
            let subpathGroups = splitIntoSubpaths(sampledPoints)

            for subpathPoints in subpathGroups {
                guard !subpathPoints.isEmpty else { continue }

                // Convert CGPoints to StitchPoints
                let stitchPoints = subpathPoints.map { point in
                    StitchPoint(x: Double(point.x), y: Double(point.y))
                }

                // Create a stitch group for this subpath
                let stitchGroup = StitchGroup(
                    id: UUID(),
                    type: .running,
                    points: stitchPoints,
                    color: color,
                    density: density
                )

                stitchGroups.append(stitchGroup)
            }
        }

        return stitchGroups
    }

    /// Split sampled points into separate arrays for each subpath
    /// Detects large gaps that indicate moveToPoint operations
    private func splitIntoSubpaths(_ points: [CGPoint]) -> [[CGPoint]] {
        guard !points.isEmpty else { return [] }

        var subpaths: [[CGPoint]] = []
        var currentSubpath: [CGPoint] = []
        let maxGapDistance: CGFloat = 10.0  // mm - threshold for detecting subpath boundary

        for i in 0..<points.count {
            let point = points[i]

            if i > 0 {
                let prevPoint = points[i - 1]
                let dx = point.x - prevPoint.x
                let dy = point.y - prevPoint.y
                let distance = sqrt(dx * dx + dy * dy)

                // Large gap indicates a moveToPoint (new subpath)
                if distance > maxGapDistance {
                    if !currentSubpath.isEmpty {
                        subpaths.append(currentSubpath)
                        currentSubpath = []
                    }
                }
            }

            currentSubpath.append(point)
        }

        // Add final subpath
        if !currentSubpath.isEmpty {
            subpaths.append(currentSubpath)
        }

        return subpaths
    }

    /// Generate outline stitches from a TextObject
    /// - Parameter textObject: The text object to generate stitches for
    /// - Returns: Array of StitchGroups
    func generateOutlineStitches(for textObject: TextObject) -> [StitchGroup] {
        // Get the font
        guard let embroideryFont = EmbroideryFontManager.shared.font(named: textObject.fontName) else {
            return []
        }

        // Convert font size from mm to points
        let pointSize = TextPathGenerator.mmToPoints(textObject.fontSize)
        let font = embroideryFont.nsFont.withSize(pointSize)

        return generateOutlineStitches(
            text: textObject.text,
            font: font,
            position: textObject.position,
            density: textObject.effectiveDensity(),
            color: textObject.outlineColor,
            letterSpacing: textObject.letterSpacing,
            alignment: textObject.alignment
        )
    }
}
