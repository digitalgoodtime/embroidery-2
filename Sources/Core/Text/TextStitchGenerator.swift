import Foundation
import AppKit

/// Unified text stitch generator that handles all stitch techniques
class TextStitchGenerator {

    private let outlineGenerator = TextOutlineStitchGenerator()
    private let pathGenerator = TextPathGenerator()

    /// Generate stitches for a text object based on its stitch technique
    /// - Parameter textObject: The text object to generate stitches for
    /// - Returns: Tuple containing (stitch groups, updated bounds)
    func generateStitches(for textObject: TextObject) -> (stitchGroups: [StitchGroup], bounds: CGRect) {
        var allStitchGroups: [StitchGroup] = []

        // Get the font
        guard let embroideryFont = EmbroideryFontManager.shared.font(named: textObject.fontName) else {
            return ([], .zero)
        }

        // Convert font size from mm to points
        let pointSize = TextPathGenerator.mmToPoints(textObject.fontSize)
        let font = embroideryFont.nsFont.withSize(pointSize)

        // Generate paths once for all techniques
        let pathResult = pathGenerator.generatePaths(
            for: textObject.text,
            font: font,
            at: textObject.position,
            letterSpacing: CGFloat(textObject.letterSpacing),
            alignment: textObject.alignment
        )

        let bounds = pathResult.bounds
        let density = textObject.effectiveDensity()

        // Generate outline stitches
        let outlineStitches = outlineGenerator.generateOutlineStitches(
            pathResult: pathResult,
            density: density,
            color: textObject.outlineColor
        )
        allStitchGroups.append(contentsOf: outlineStitches)

        return (allStitchGroups, bounds)
    }

    /// Validate a text object for embroidery
    /// - Parameter textObject: Text object to validate
    /// - Returns: Array of validation warnings/errors
    func validate(_ textObject: TextObject) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []

        // Check minimum size
        if textObject.fontSize < 8.0 {
            issues.append(ValidationIssue(
                severity: .warning,
                message: "Text size (\(String(format: "%.1f", textObject.fontSize))mm) is below recommended minimum (8mm). Text may be difficult to read."
            ))
        }

        // Check maximum size (for typical hoop)
        if textObject.fontSize > 100.0 {
            issues.append(ValidationIssue(
                severity: .warning,
                message: "Text size (\(String(format: "%.1f", textObject.fontSize))mm) is very large. Ensure it fits within your hoop."
            ))
        }

        // Check empty text
        if textObject.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(ValidationIssue(
                severity: .error,
                message: "Text cannot be empty."
            ))
        }

        // Check density
        let density = textObject.effectiveDensity()
        if density < 2.0 {
            issues.append(ValidationIssue(
                severity: .warning,
                message: "Stitch density (\(String(format: "%.1f", density)) stitches/mm) is low. Fill may have gaps."
            ))
        } else if density > 8.0 {
            issues.append(ValidationIssue(
                severity: .warning,
                message: "Stitch density (\(String(format: "%.1f", density)) stitches/mm) is very high. This may be difficult to stitch and could damage fabric."
            ))
        }

        return issues
    }

    struct ValidationIssue {
        enum Severity {
            case error
            case warning
            case info
        }

        let severity: Severity
        let message: String
    }
}
