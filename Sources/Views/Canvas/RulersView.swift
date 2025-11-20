//
//  RulersView.swift
//  EmbroideryStudio
//
//  Canvas rulers for precise measurement with liquid glass polish
//

import SwiftUI

struct RulersView: View {
    let zoomLevel: Double
    let canvasOffset: CGPoint
    let orientation: Orientation

    enum Orientation {
        case horizontal
        case vertical
    }

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let rulerSize = orientation == .horizontal ? size.width : size.height
                let measurementUnit: Double = 10.0 // 10mm increments
                let scaledUnit = measurementUnit * zoomLevel

                // Background
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .color(Color.surfaceSecondary.opacity(.opacityNearFull))
                )

                // Draw tick marks
                let offset = orientation == .horizontal ? canvasOffset.x : canvasOffset.y
                let startValue = -offset / zoomLevel
                let numberOfTicks = Int(rulerSize / scaledUnit) + 2

                for i in 0...numberOfTicks {
                    let value = startValue + Double(i) * measurementUnit
                    let position = (value * zoomLevel) + offset

                    if position >= 0 && position <= rulerSize {
                        let isMajor = Int(value) % 50 == 0
                        let isMinor = Int(value) % 10 == 0

                        var tickHeight: CGFloat = .spacing1
                        var tickWidth: CGFloat = .lineHairline

                        if isMajor {
                            tickHeight = .spacing3
                            tickWidth = .lineStandard
                        } else if isMinor {
                            tickHeight = .spacing2
                        }

                        let tickPath: Path
                        if orientation == .horizontal {
                            tickPath = Path { path in
                                path.move(to: CGPoint(x: position, y: size.height))
                                path.addLine(to: CGPoint(x: position, y: size.height - tickHeight))
                            }
                        } else {
                            tickPath = Path { path in
                                path.move(to: CGPoint(x: size.width, y: position))
                                path.addLine(to: CGPoint(x: size.width - tickHeight, y: position))
                            }
                        }

                        context.stroke(
                            tickPath,
                            with: .color(.textSecondary),
                            lineWidth: tickWidth
                        )

                        // Draw labels for major ticks
                        if isMajor && scaledUnit > 20 {
                            let label = Text("\(Int(value))")
                                .font(.system(size: .iconSmall - 1))
                                .foregroundColor(.textSecondary)

                            if orientation == .horizontal {
                                context.draw(label, at: CGPoint(x: position + .spacing0_5, y: size.height - .spacing4))
                            } else {
                                context.draw(label, at: CGPoint(x: size.width - .spacing4 - .spacing0_5, y: position + .spacing0_5))
                            }
                        }
                    }
                }

                // Draw border
                let borderPath: Path
                if orientation == .horizontal {
                    borderPath = Path { path in
                        path.move(to: CGPoint(x: 0, y: size.height))
                        path.addLine(to: CGPoint(x: size.width, y: size.height))
                    }
                } else {
                    borderPath = Path { path in
                        path.move(to: CGPoint(x: size.width, y: 0))
                        path.addLine(to: CGPoint(x: size.width, y: size.height))
                    }
                }

                context.stroke(
                    borderPath,
                    with: .color(Color.borderDefault),
                    lineWidth: .lineStandard
                )
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Ruler Corner

struct RulerCorner: View {
    var body: some View {
        Rectangle()
            .fill(Color.surfaceSecondary.opacity(.opacityNearFull))
            .overlay {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: .iconTiny))
                    .foregroundColor(.textSecondary)
            }
            .border(Color.borderDefault, width: .lineStandard)
            .accessibilityHidden(true)
    }
}
