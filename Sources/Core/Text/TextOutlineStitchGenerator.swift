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
            // Sample points along the path, split by subpath
            let subpathGroups = pathGenerator.samplePathBySubpath(glyphPath.path, density: density)

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

    /// Generate outline stitches from pre-generated path result
    /// - Parameters:
    ///   - pathResult: The path result containing glyph paths
    ///   - density: Stitch density
    ///   - color: Thread color
    /// - Returns: Array of StitchGroups
    func generateOutlineStitches(
        pathResult: TextPathGenerator.PathResult,
        density: Double,
        color: CodableColor
    ) -> [StitchGroup] {
        var stitchGroups: [StitchGroup] = []

        // Process each glyph path
        for glyphPath in pathResult.glyphPaths {
            // Sample points along the path, split by subpath
            let subpathGroups = pathGenerator.samplePathBySubpath(glyphPath.path, density: density)

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
}
