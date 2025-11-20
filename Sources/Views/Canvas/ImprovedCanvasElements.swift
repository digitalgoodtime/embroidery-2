//
//  ImprovedCanvasElements.swift
//  EmbroideryStudio
//
//  Enhanced canvas UI elements for better visual presentation
//

import SwiftUI

// MARK: - Improved Grid View

extension GridView {
    /// Improved grid with major/minor lines
    var improvedBody: some View {
        Canvas { context, size in
            let scaledGridSize = gridSize * zoomLevel
            
            guard scaledGridSize > 2 else { return }
            
            let rows = Int(size.height / scaledGridSize) + 1
            let cols = Int(size.width / scaledGridSize) + 1
            
            // Minor grid lines (every unit)
            context.stroke(
                Path { path in
                    for i in 0...cols {
                        let x = CGFloat(i) * scaledGridSize
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    }
                    
                    for i in 0...rows {
                        let y = CGFloat(i) * scaledGridSize
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }
                },
                with: .color(.gray.opacity(0.15)),
                lineWidth: 0.5
            )
            
            // Major grid lines (every 10 units)
            if scaledGridSize > 10 {
                context.stroke(
                    Path { path in
                        for i in stride(from: 0, through: cols, by: 10) {
                            let x = CGFloat(i) * scaledGridSize
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: size.height))
                        }
                        
                        for i in stride(from: 0, through: rows, by: 10) {
                            let y = CGFloat(i) * scaledGridSize
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: size.width, y: y))
                        }
                    },
                    with: .color(.gray.opacity(0.3)),
                    lineWidth: 1
                )
            }
        }
    }
}

// MARK: - Improved Hoop View

extension HoopView {
    /// Improved hoop with shadow and label
    var improvedBody: some View {
        let dimensions = hoopSize.dimensions
        let width = dimensions.width * zoomLevel
        let height = dimensions.height * zoomLevel
        
        return ZStack {
            // Shadow/glow
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.accentColor.opacity(0.2), lineWidth: 4)
                .frame(width: width + 4, height: height + 4)
                .blur(radius: 4)
            
            // Main hoop outline
            RoundedRectangle(cornerRadius: 6)
                .stroke(
                    LinearGradient(
                        colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                )
                .frame(width: width, height: height)
            
            // Hoop size label
            VStack {
                Spacer()
                Text(hoopSize.rawValue)
                    .font(.caption.monospacedDigit())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(4)
                    .offset(y: height / 2 + 20)
            }
        }
    }
}
