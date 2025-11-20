import Foundation
import CoreGraphics

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
    func generateOutlineStitches(
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

            // Convert CGPoints to StitchPoints
            let stitchPoints = sampledPoints.map { point in
                StitchPoint(x: Double(point.x), y: Double(point.y))
            }

            // Create a stitch group for this character outline
            let stitchGroup = StitchGroup(
                id: UUID(),
                type: .running,
                points: stitchPoints,
                color: color,
                density: density
            )

            stitchGroups.append(stitchGroup)
        }

        return stitchGroups
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
