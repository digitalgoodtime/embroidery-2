import Foundation
import SwiftUI

/// Manages state for the text tool - holds all text properties configured in the properties panel
class TextToolState: ObservableObject {
    static let shared = TextToolState()

    // Text content
    @Published var text: String = "Text"
    @Published var searchQuery: String = ""

    // Font settings
    @Published var selectedFont: EmbroideryFont
    @Published var fontSize: Double = 20.0 // mm
    @Published var letterSpacing: Double = 0.0
    @Published var alignment: TextObject.TextAlignment = .left

    // Embroidery settings
    @Published var stitchTechnique: TextStitchTechnique = .fillWithOutline
    @Published var densityMode: TextObject.DensityMode = .auto
    @Published var manualDensity: Double = 4.0
    @Published var outlineColor: CodableColor = CodableColor(.black)
    @Published var fillColor: CodableColor = CodableColor(.black)

    private let fontManager = EmbroideryFontManager.shared
    private let stitchGenerator = TextStitchGenerator()

    private init() {
        // Initialize with default font
        self.selectedFont = fontManager.defaultFont()
    }

    /// Create a TextObject from current state
    func createTextObject(at position: CGPoint) -> TextObject {
        TextObject(
            text: text,
            position: position,
            fontSize: fontSize,
            fontName: selectedFont.id,
            letterSpacing: letterSpacing,
            alignment: alignment,
            stitchTechnique: stitchTechnique,
            densityMode: densityMode,
            manualDensity: manualDensity,
            outlineColor: outlineColor,
            fillColor: stitchTechnique.needsFill ? fillColor : nil
        )
    }

    /// Validate current text settings
    func validate() -> [TextStitchGenerator.ValidationIssue] {
        let textObject = createTextObject(at: .zero)
        return stitchGenerator.validate(textObject)
    }

    /// Calculate auto density based on current font size
    func calculateAutoDensity() -> Double {
        let minDensity = 3.0
        let maxDensity = 5.0
        let minSize = 8.0
        let maxSize = 50.0

        let normalized = (fontSize - minSize) / (maxSize - minSize)
        let clamped = max(0, min(1, normalized))

        return maxDensity - (clamped * (maxDensity - minDensity))
    }

    /// Get filtered fonts based on search query
    func filteredFonts() -> [EmbroideryFont] {
        if searchQuery.isEmpty {
            return fontManager.allFonts
        }
        return fontManager.searchFonts(query: searchQuery)
    }
}
