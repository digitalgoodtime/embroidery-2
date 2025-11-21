import Foundation
import AppKit

/// Represents a font available for embroidery with metadata about its suitability
struct EmbroideryFont: Identifiable, Hashable {
    let id: String // font name
    let displayName: String
    let familyName: String
    let difficulty: EmbroideryDifficulty
    let nsFont: NSFont

    enum EmbroideryDifficulty: String, Comparable {
        case easy = "Easy"
        case medium = "Medium"
        case complex = "Complex"

        var icon: String {
            switch self {
            case .easy:
                return "checkmark.circle.fill"
            case .medium:
                return "minus.circle.fill"
            case .complex:
                return "exclamationmark.circle.fill"
            }
        }

        var color: NSColor {
            switch self {
            case .easy:
                return .systemGreen
            case .medium:
                return .systemYellow
            case .complex:
                return .systemOrange
            }
        }

        var description: String {
            switch self {
            case .easy:
                return "Simple shapes, clean stitching"
            case .medium:
                return "Moderate detail, good for most uses"
            case .complex:
                return "Intricate details, may be challenging"
            }
        }

        static func < (lhs: EmbroideryDifficulty, rhs: EmbroideryDifficulty) -> Bool {
            let order: [EmbroideryDifficulty] = [.easy, .medium, .complex]
            guard let lhsIndex = order.firstIndex(of: lhs),
                  let rhsIndex = order.firstIndex(of: rhs) else {
                return false
            }
            return lhsIndex < rhsIndex
        }
    }

    static func == (lhs: EmbroideryFont, rhs: EmbroideryFont) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// Manages system fonts and rates them for embroidery suitability
class EmbroideryFontManager: ObservableObject {
    static let shared = EmbroideryFontManager()

    @Published private(set) var allFonts: [EmbroideryFont] = []
    @Published private(set) var fontsByFamily: [String: [EmbroideryFont]] = [:]

    private init() {
        loadSystemFonts()
    }

    /// Load all available system fonts and rate them
    func loadSystemFonts() {
        let fontManager = NSFontManager.shared
        let families = fontManager.availableFontFamilies

        var fonts: [EmbroideryFont] = []

        for family in families {
            guard let members = fontManager.availableMembers(ofFontFamily: family) else {
                continue
            }

            for member in members {
                guard let fontName = member[0] as? String,
                      let displayName = member[1] as? String,
                      let nsFont = NSFont(name: fontName, size: 12) else {
                    continue
                }

                let difficulty = rateFontDifficulty(fontName: fontName, family: family)

                let embroideryFont = EmbroideryFont(
                    id: fontName,
                    displayName: displayName,
                    familyName: family,
                    difficulty: difficulty,
                    nsFont: nsFont
                )

                fonts.append(embroideryFont)
            }
        }

        // Sort by difficulty, then by name
        fonts.sort { lhs, rhs in
            if lhs.difficulty == rhs.difficulty {
                return lhs.displayName < rhs.displayName
            }
            return lhs.difficulty < rhs.difficulty
        }

        allFonts = fonts

        // Group by family
        fontsByFamily = Dictionary(grouping: fonts) { $0.familyName }
    }

    /// Rate a font's difficulty for embroidery based on characteristics
    private func rateFontDifficulty(fontName: String, family: String) -> EmbroideryFont.EmbroideryDifficulty {
        let name = fontName.lowercased()
        let familyLower = family.lowercased()

        // Easy fonts: Sans-serif, bold, simple
        let easyKeywords = ["helvetica", "arial", "impact", "futura", "avenir", "din", "franklin"]
        let boldKeywords = ["bold", "black", "heavy"]

        // Complex fonts: Script, decorative, thin
        let complexKeywords = ["script", "brush", "calligraphy", "handwriting", "cursive", "ornament", "decorative"]
        let thinKeywords = ["thin", "light", "ultra light", "hairline"]

        // Serif fonts are generally medium difficulty
        let serifKeywords = ["times", "georgia", "baskerville", "garamond", "palatino"]

        // Check for complex characteristics first
        if complexKeywords.contains(where: { name.contains($0) || familyLower.contains($0) }) {
            return .complex
        }

        if thinKeywords.contains(where: { name.contains($0) }) {
            return .complex
        }

        // Check for easy characteristics
        if easyKeywords.contains(where: { familyLower.contains($0) }) {
            if boldKeywords.contains(where: { name.contains($0) }) {
                return .easy
            }
            return .easy
        }

        // Bold variants are easier
        if boldKeywords.contains(where: { name.contains($0) }) {
            return .easy
        }

        // Serif fonts default to medium
        if serifKeywords.contains(where: { familyLower.contains($0) }) {
            return .medium
        }

        // Default to medium
        return .medium
    }

    /// Get a font by name
    func font(named name: String) -> EmbroideryFont? {
        allFonts.first { $0.id == name }
    }

    /// Get default font for embroidery
    func defaultFont() -> EmbroideryFont {
        // Try to find Helvetica Bold
        if let helveticaBold = allFonts.first(where: { $0.familyName == "Helvetica" && $0.displayName.contains("Bold") }) {
            return helveticaBold
        }

        // Fallback to first easy font
        if let firstEasy = allFonts.first(where: { $0.difficulty == .easy }) {
            return firstEasy
        }

        // Ultimate fallback
        return allFonts.first ?? EmbroideryFont(
            id: "Helvetica-Bold",
            displayName: "Helvetica Bold",
            familyName: "Helvetica",
            difficulty: .easy,
            nsFont: NSFont.boldSystemFont(ofSize: 12)
        )
    }

    /// Search fonts by name
    func searchFonts(query: String) -> [EmbroideryFont] {
        guard !query.isEmpty else { return allFonts }

        let lowercaseQuery = query.lowercased()
        return allFonts.filter {
            $0.displayName.lowercased().contains(lowercaseQuery) ||
            $0.familyName.lowercased().contains(lowercaseQuery)
        }
    }
}
