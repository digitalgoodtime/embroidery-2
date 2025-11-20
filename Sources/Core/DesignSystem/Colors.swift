//
//  Colors.swift
//  EmbroideryStudio
//
//  Design system - Semantic color system with Liquid Glass support
//

import SwiftUI

extension Color {
    // MARK: - Surface Colors (Liquid Glass)

    /// Primary window background
    static let surfacePrimary = Color(nsColor: .windowBackgroundColor)

    /// Secondary control background
    static let surfaceSecondary = Color(nsColor: .controlBackgroundColor)

    /// Tertiary subtle background
    static let surfaceTertiary = Color(nsColor: .controlBackgroundColor).opacity(.opacityMedium)

    /// Canvas/content background
    static let surfaceCanvas = Color(nsColor: .controlBackgroundColor)

    // MARK: - Interactive States

    /// Hover background (light, subtle)
    static let interactiveHover = Color.secondary.opacity(.opacityLight)

    /// Hover background (stronger emphasis)
    static let interactiveHoverStrong = Color.secondary.opacity(.opacityLightMedium)

    /// Selected/active background
    static let interactiveSelected = Color.accentColor.opacity(.opacityMedium)

    /// Pressed/active state
    static let interactivePressed = Color.accentColor.opacity(.opacityMediumStrong)

    /// Focus ring color
    static let interactiveFocus = Color.accentColor

    // MARK: - Border Colors

    /// Default separator/border
    static let borderDefault = Color(nsColor: .separatorColor)

    /// Subtle border
    static let borderSubtle = Color(nsColor: .separatorColor).opacity(.opacityDisabled)

    /// Emphasized border
    static let borderEmphasis = Color(nsColor: .separatorColor).opacity(.opacityHigh)

    /// Focus/selected border
    static let borderFocus = Color.accentColor.opacity(.opacityStrong)

    /// Accent border
    static let borderAccent = Color.accentColor.opacity(.opacityMediumStrong)

    // MARK: - Text Colors

    /// Primary text (full emphasis)
    static let textPrimary = Color.primary

    /// Secondary text (reduced emphasis)
    static let textSecondary = Color.secondary

    /// Tertiary text (minimal emphasis)
    static let textTertiary = Color.secondary.opacity(.opacitySecondary)

    /// Disabled text
    static let textDisabled = Color.primary.opacity(.opacityDisabled)

    /// Accent/link text
    static let textAccent = Color.accentColor

    /// On accent background (white)
    static let textOnAccent = Color.white

    // MARK: - Status Colors

    /// Locked state (orange)
    static let statusLocked = Color.orange.opacity(.opacityVeryHigh)

    /// Hidden/invisible state (red)
    static let statusHidden = Color.red.opacity(.opacityHigh)

    /// Visible/active state
    static let statusVisible = Color.primary.opacity(.opacitySecondary)

    /// Success state
    static let statusSuccess = Color.green

    /// Warning state
    static let statusWarning = Color.orange

    /// Error state
    static let statusError = Color.red

    /// Info state
    static let statusInfo = Color.blue

    // MARK: - Accent Variations

    /// Accent color with subtle opacity for backgrounds
    static let accentSubtle = Color.accentColor.opacity(.opacitySubtle)

    /// Accent color with light opacity
    static let accentLight = Color.accentColor.opacity(.opacityLight)

    /// Accent color with medium-light opacity
    static let accentMediumLight = Color.accentColor.opacity(.opacityMediumLight)

    /// Accent color with medium opacity
    static let accentMedium = Color.accentColor.opacity(.opacityMedium)

    /// Accent color with strong opacity
    static let accentStrong = Color.accentColor.opacity(.opacityStrong)

    /// Accent color with high opacity
    static let accentHigh = Color.accentColor.opacity(.opacityHigh)

    // MARK: - Overlay Colors (Liquid Glass)

    /// Very subtle overlay for hover states
    static let overlaySubtle = Color.black.opacity(.opacitySubtle)

    /// Light overlay for modals
    static let overlayLight = Color.black.opacity(.opacityLight)

    /// Medium overlay for modal backgrounds
    static let overlayMedium = Color.black.opacity(.opacityMedium)

    /// Strong overlay for focused modals
    static let overlayStrong = Color.black.opacity(.opacityDisabled)
}
