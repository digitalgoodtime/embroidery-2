//
//  Typography.swift
//  EmbroideryStudio
//
//  Design system - Typography scale and semantic font styles
//

import SwiftUI

extension Font {
    // MARK: - Headings

    /// Large heading (34pt, bold, rounded) - Hero sections
    static let headingHero = Font.system(size: 34, weight: .bold, design: .rounded)

    /// Large heading (22pt, bold) - Modal titles
    static let headingLarge = Font.system(.title2, design: .default, weight: .bold)

    /// Medium heading (18-20pt, semibold) - Section headers
    static let headingMedium = Font.system(.title3, design: .default, weight: .semibold)

    /// Small heading (14pt, semibold) - Subsection headers
    static let headingSmall = Font.system(.subheadline, design: .default, weight: .semibold)

    // MARK: - Body Text

    /// Default body text (15pt, regular)
    static let bodyDefault = Font.system(.body)

    /// Emphasized body text (15pt, medium)
    static let bodyEmphasis = Font.system(.body, design: .default, weight: .medium)

    /// Semibold body text (15pt, semibold)
    static let bodySemibold = Font.system(.body, design: .default, weight: .semibold)

    /// Bold body text (15pt, bold)
    static let bodyBold = Font.system(.body, design: .default, weight: .bold)

    // MARK: - UI Elements

    /// Label text (11-12pt, medium) - Form labels, headers
    static let label = Font.system(.caption, design: .default, weight: .medium)

    /// Label semibold (11-12pt, semibold)
    static let labelSemibold = Font.system(.caption, design: .default, weight: .semibold)

    /// Caption text (11-12pt, regular) - Secondary descriptions
    static let caption = Font.system(.caption)

    /// Small caption (9-10pt, regular) - Tertiary info
    static let captionSmall = Font.system(.caption2)

    /// Small caption medium weight (9-10pt, medium)
    static let captionSmallMedium = Font.system(.caption2, design: .default, weight: .medium)

    // MARK: - Special Purpose

    /// Monospaced text for numbers and measurements (11-12pt)
    static let mono = Font.system(.caption, design: .monospaced)

    /// Monospaced medium weight (11-12pt, medium)
    static let monoMedium = Font.system(.caption, design: .monospaced, weight: .medium)

    /// Monospaced body (15pt, monospaced)
    static let monoBody = Font.system(.body, design: .monospaced)

    /// Rounded design for casual/status text (11-12pt)
    static let rounded = Font.system(.caption, design: .rounded)

    /// Rounded medium (11-12pt, medium, rounded)
    static let roundedMedium = Font.system(.caption, design: .rounded, weight: .medium)

    /// Rounded body (15pt, rounded)
    static let roundedBody = Font.system(.body, design: .rounded)

    // MARK: - Tool-Specific

    /// Tool icon font size (18pt, regular)
    static func toolIcon(size: CGFloat = .iconMediumLarge) -> Font {
        Font.system(size: size, weight: .regular)
    }

    /// Status icon font size (10-14pt)
    static func statusIcon(size: CGFloat = .iconSmall) -> Font {
        Font.system(size: size)
    }

    /// Button text (13pt, medium)
    static let button = Font.system(size: 13, weight: .medium)

    /// Button text semibold (13pt, semibold)
    static let buttonSemibold = Font.system(size: 13, weight: .semibold)
}

// MARK: - Font Weights Extension

extension Font.Weight {
    /// Light weight (300)
    static let light = Font.Weight.light

    /// Regular weight (400)
    static let regular = Font.Weight.regular

    /// Medium weight (500)
    static let medium = Font.Weight.medium

    /// Semibold weight (600)
    static let semibold = Font.Weight.semibold

    /// Bold weight (700)
    static let bold = Font.Weight.bold
}
