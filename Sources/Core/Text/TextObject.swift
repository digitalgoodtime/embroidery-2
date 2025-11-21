import Foundation
import SwiftUI

/// Represents a text object in the embroidery design with all embroidery-specific properties
struct TextObject: Identifiable, Codable {
    var id: UUID = UUID()

    // Text content and layout
    var text: String
    var position: CGPoint
    var fontSize: Double // in mm
    var fontName: String
    var letterSpacing: Double = 0.0 // additional spacing in mm
    var alignment: TextAlignment = .left

    // Embroidery stitch properties
    var stitchTechnique: TextStitchTechnique = .fillWithOutline
    var densityMode: DensityMode = .auto
    var manualDensity: Double = 4.0 // stitches per mm when in manual mode
    var outlineColor: CodableColor
    var fillColor: CodableColor?

    // Computed and cached properties
    var bounds: CGRect = .zero // calculated after path generation
    var stitchCount: Int = 0 // total stitch count

    enum TextAlignment: String, Codable {
        case left
        case center
        case right
    }

    enum DensityMode: String, Codable {
        case auto // calculate based on font size
        case manual // use manualDensity value
    }

    /// Calculate optimal density based on font size
    /// Smaller text needs higher density for clarity
    func calculateAutoDensity() -> Double {
        // Formula: larger text = lower density, smaller = higher
        // 8mm (minimum) = 5.0 stitches/mm
        // 20mm (medium) = 4.0 stitches/mm
        // 50mm (large) = 3.0 stitches/mm
        let minDensity = 3.0
        let maxDensity = 5.0
        let minSize = 8.0
        let maxSize = 50.0

        let normalized = (fontSize - minSize) / (maxSize - minSize)
        let clamped = max(0, min(1, normalized))

        return maxDensity - (clamped * (maxDensity - minDensity))
    }

    /// Get the effective density to use for stitch generation
    func effectiveDensity() -> Double {
        switch densityMode {
        case .auto:
            return calculateAutoDensity()
        case .manual:
            return manualDensity
        }
    }

    /// Check if a point is within this text object's bounds
    func contains(point: CGPoint, tolerance: Double = 10.0) -> Bool {
        // Expand bounds by tolerance for easier selection
        let expandedBounds = bounds.insetBy(dx: -tolerance, dy: -tolerance)
        return expandedBounds.contains(point)
    }

    /// Update bounds after path generation
    mutating func updateBounds(_ newBounds: CGRect) {
        bounds = newBounds
    }
}

/// Embroidery stitch technique for text rendering
enum TextStitchTechnique: String, Codable, CaseIterable {
    case outline = "Outline"
    case fill = "Fill"
    case fillWithOutline = "Fill + Outline"

    var icon: String {
        switch self {
        case .outline:
            return "text.cursor"
        case .fill:
            return "square.fill"
        case .fillWithOutline:
            return "square.fill.on.square"
        }
    }

    var description: String {
        switch self {
        case .outline:
            return "Running stitch along character outlines"
        case .fill:
            return "Satin fill inside characters"
        case .fillWithOutline:
            return "Fill with outline border"
        }
    }

    var needsFill: Bool {
        self == .fill || self == .fillWithOutline
    }

    var needsOutline: Bool {
        self == .outline || self == .fillWithOutline
    }
}
