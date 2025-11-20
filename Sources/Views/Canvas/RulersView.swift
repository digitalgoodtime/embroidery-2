//
//  RulersView.swift
//  EmbroideryStudio
//
//  Canvas rulers for precise measurement
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
                    with: .color(Color(nsColor: .controlBackgroundColor).opacity(0.95))
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

                        var tickHeight: CGFloat = 4
                        var tickWidth: CGFloat = 0.5

                        if isMajor {
                            tickHeight = 12
                            tickWidth = 1
                        } else if isMinor {
                            tickHeight = 8
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
                            with: .color(.secondary),
                            lineWidth: tickWidth
                        )

                        // Draw labels for major ticks
                        if isMajor && scaledUnit > 20 {
                            let label = Text("\(Int(value))")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)

                            if orientation == .horizontal {
                                context.draw(label, at: CGPoint(x: position + 2, y: size.height - 16))
                            } else {
                                context.draw(label, at: CGPoint(x: size.width - 18, y: position + 2))
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
                    with: .color(Color(nsColor: .separatorColor)),
                    lineWidth: 1
                )
            }
        }
    }
}

// MARK: - Ruler Corner

struct RulerCorner: View {
    var body: some View {
        Rectangle()
            .fill(Color(nsColor: .controlBackgroundColor).opacity(0.95))
            .overlay {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .border(Color(nsColor: .separatorColor), width: 1)
    }
}
