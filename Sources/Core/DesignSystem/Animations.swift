//
//  Animations.swift
//  EmbroideryStudio
//
//  Design system - Animation and transition standards
//

import SwiftUI

extension Animation {
    // MARK: - UI Transitions

    /// Fast UI transitions (0.1s) - Quick hover states
    static let uiFast = Animation.easeInOut(duration: 0.1)

    /// Default UI transitions (0.15s) - Standard interactions
    static let uiDefault = Animation.easeInOut(duration: 0.15)

    /// Slow UI transitions (0.2s) - Panel toggles, larger movements
    static let uiSlow = Animation.easeInOut(duration: 0.2)

    /// Medium transitions (0.25s) - Modal presentations
    static let uiMedium = Animation.easeInOut(duration: 0.25)

    /// Smooth transitions (0.3s) - Smooth, polished movements
    static let uiSmooth = Animation.easeInOut(duration: 0.3)

    // MARK: - Spring Animations (Liquid Glass)

    /// Quick spring (0.3s response) - Layer operations, list updates
    static let springQuick = Animation.spring(response: 0.3, dampingFraction: 0.7)

    /// Default spring (0.4s response) - Standard bouncy interactions
    static let springDefault = Animation.spring(response: 0.4, dampingFraction: 0.75)

    /// Smooth spring (0.5s response) - Smooth, gentle bounces
    static let springSmooth = Animation.spring(response: 0.5, dampingFraction: 0.8)

    /// Bouncy spring (0.4s response, less damping) - Playful interactions
    static let springBouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)

    // MARK: - Specialized Animations

    /// Fade animations (0.2s) - Opacity changes
    static let fade = Animation.easeInOut(duration: 0.2)

    /// Scale animations (0.15s) - Size changes
    static let scale = Animation.easeOut(duration: 0.15)

    /// Slide animations (0.25s) - Sliding panels
    static let slide = Animation.easeInOut(duration: 0.25)
}

// MARK: - Transition Presets

extension AnyTransition {
    /// Fade in/out transition
    static let fadeTransition = AnyTransition.opacity.animation(.fade)

    /// Scale and fade transition
    static let scaleAndFade = AnyTransition.scale.combined(with: .opacity).animation(.scale)

    /// Slide from leading edge
    static let slideFromLeading = AnyTransition.move(edge: .leading).animation(.slide)

    /// Slide from trailing edge
    static let slideFromTrailing = AnyTransition.move(edge: .trailing).animation(.slide)

    /// Slide from top
    static let slideFromTop = AnyTransition.move(edge: .top).animation(.slide)

    /// Slide from bottom
    static let slideFromBottom = AnyTransition.move(edge: .bottom).animation(.slide)
}

// MARK: - Animation Duration Constants

extension TimeInterval {
    /// 0.1 seconds - Very fast
    static let durationFast = 0.1

    /// 0.15 seconds - Default fast
    static let durationDefault = 0.15

    /// 0.2 seconds - Standard
    static let durationStandard = 0.2

    /// 0.25 seconds - Medium
    static let durationMedium = 0.25

    /// 0.3 seconds - Smooth
    static let durationSmooth = 0.3

    /// 0.4 seconds - Slow
    static let durationSlow = 0.4

    /// 0.5 seconds - Very slow
    static let durationVerySlow = 0.5
}
