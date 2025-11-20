//
//  Spacing.swift
//  EmbroideryStudio
//
//  Design system - Spacing scale for consistent layout
//

import SwiftUI

extension CGFloat {
    // MARK: - Spacing Scale
    // Based on 4px base unit for consistent rhythm

    /// 2px - Minimal spacing for tightly grouped elements
    static let spacing0_5 = CGFloat(2)

    /// 4px - Smallest spacing unit
    static let spacing1 = CGFloat(4)

    /// 6px - Compact spacing for related items
    static let spacing1_5 = CGFloat(6)

    /// 8px - Small spacing for closely related content
    static let spacing2 = CGFloat(8)

    /// 10px - Medium-small spacing
    static let spacing2_5 = CGFloat(10)

    /// 12px - Standard spacing for component internals
    static let spacing3 = CGFloat(12)

    /// 14px - Medium spacing
    static let spacing3_5 = CGFloat(14)

    /// 16px - Base spacing unit (1rem equivalent)
    static let spacing4 = CGFloat(16)

    /// 20px - Medium-large spacing
    static let spacing5 = CGFloat(20)

    /// 24px - Large spacing for separated sections
    static let spacing6 = CGFloat(24)

    /// 28px - Extra large spacing
    static let spacing7 = CGFloat(28)

    /// 32px - Extra large spacing for major sections
    static let spacing8 = CGFloat(32)

    /// 40px - Spacious layout spacing
    static let spacing10 = CGFloat(40)

    /// 48px - Maximum spacing for hero sections
    static let spacing12 = CGFloat(48)
}
