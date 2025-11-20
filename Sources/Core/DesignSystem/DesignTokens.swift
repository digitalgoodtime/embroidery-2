//
//  DesignTokens.swift
//  EmbroideryStudio
//
//  Design system - Core design tokens for opacity, corner radius, shadows, and elevation
//

import SwiftUI

// MARK: - Opacity Scale

extension Double {
    /// 0.05 - Very subtle overlays and backgrounds
    static let opacitySubtle = 0.05

    /// 0.08 - Subtle hover states
    static let opacityLight = 0.08

    /// 0.12 - Light interactive states
    static let opacityLightMedium = 0.12

    /// 0.15 - Medium-light emphasis
    static let opacityMediumLight = 0.15

    /// 0.2 - Medium emphasis backgrounds
    static let opacityMedium = 0.2

    /// 0.25 - Medium-strong emphasis
    static let opacityMediumStrong = 0.25

    /// 0.3 - Strong emphasis elements
    static let opacityStrong = 0.3

    /// 0.4 - Very strong backgrounds
    static let opacityVeryStrong = 0.4

    /// 0.5 - Disabled state
    static let opacityDisabled = 0.5

    /// 0.6 - Muted content
    static let opacityMuted = 0.6

    /// 0.7 - Secondary elements
    static let opacitySecondary = 0.7

    /// 0.8 - High emphasis
    static let opacityHigh = 0.8

    /// 0.9 - Very high emphasis
    static let opacityVeryHigh = 0.9

    /// 0.95 - Near opaque
    static let opacityNearFull = 0.95
}

// MARK: - Corner Radius (Liquid Glass Style - Softer, Larger)

extension CGFloat {
    /// 4px - Minimal radius for small elements
    static let radiusXSmall = CGFloat(4)

    /// 6px - Small radius for compact elements
    static let radiusSmall = CGFloat(6)

    /// 8px - Medium radius (standard for cards and panels) - Liquid Glass
    static let radiusMedium = CGFloat(8)

    /// 10px - Medium-large radius
    static let radiusMediumLarge = CGFloat(10)

    /// 12px - Large radius for major panels - Liquid Glass
    static let radiusLarge = CGFloat(12)

    /// 16px - Extra large radius for hero elements
    static let radiusXLarge = CGFloat(16)

    /// 20px - Maximum radius for special elements
    static let radiusXXLarge = CGFloat(20)
}

// MARK: - Shadows (Liquid Glass Depth)

extension View {
    /// Subtle shadow for slight elevation
    func shadowSubtle() -> some View {
        self.shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
    }

    /// Light shadow for cards and floating elements
    func shadowLight() -> some View {
        self.shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }

    /// Medium shadow for elevated panels - Liquid Glass standard
    func shadowMedium() -> some View {
        self.shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
    }

    /// Strong shadow for floating palettes and modals
    func shadowStrong() -> some View {
        self.shadow(color: .black.opacity(0.16), radius: 16, x: 0, y: 8)
    }

    /// Dramatic shadow for top-level overlays
    func shadowDramatic() -> some View {
        self.shadow(color: .black.opacity(0.24), radius: 24, x: 0, y: 12)
    }
}

// MARK: - Icon Sizes

extension CGFloat {
    /// 10px - Tiny icons
    static let iconTiny = CGFloat(10)

    /// 12px - Small icons
    static let iconSmall = CGFloat(12)

    /// 14px - Medium-small icons
    static let iconMediumSmall = CGFloat(14)

    /// 16px - Medium icons
    static let iconMedium = CGFloat(16)

    /// 18px - Medium-large icons (standard tool icons)
    static let iconMediumLarge = CGFloat(18)

    /// 20px - Large icons
    static let iconLarge = CGFloat(20)

    /// 22px - Extra large icons
    static let iconXLarge = CGFloat(22)

    /// 24px - Prominent icons
    static let iconXXLarge = CGFloat(24)

    /// 52px - Hero icons
    static let iconHero = CGFloat(52)

    /// 90px - Extra large hero icons
    static let iconHeroXL = CGFloat(90)
}

// MARK: - Component Dimensions

extension CGFloat {
    // Button and control heights
    static let controlSmall = CGFloat(24)
    static let controlMedium = CGFloat(28)
    static let controlLarge = CGFloat(32)
    static let controlXLarge = CGFloat(38)

    // Toolbar and panel heights
    static let toolbarHeight = CGFloat(44)
    static let statusBarHeight = CGFloat(28)
    static let toolPaletteWidth = CGFloat(52)

    // Sidebar constraints
    static let sidebarMinWidth = CGFloat(200)
    static let sidebarMaxWidth = CGFloat(400)
    static let sidebarDefaultWidth = CGFloat(250)
    static let propertiesSidebarDefaultWidth = CGFloat(280)
}

// MARK: - Line Widths

extension CGFloat {
    /// 0.5px - Hairline borders
    static let lineHairline = CGFloat(0.5)

    /// 1px - Standard border
    static let lineStandard = CGFloat(1)

    /// 1.5px - Emphasized border
    static let lineEmphasis = CGFloat(1.5)

    /// 2px - Strong border
    static let lineStrong = CGFloat(2)

    /// 3px - Very strong border
    static let lineVeryStrong = CGFloat(3)
}
