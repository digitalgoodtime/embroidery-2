//
//  CanvasView.swift
//  EmbroideryStudio
//
//  Main canvas view for displaying and editing embroidery designs
//

import SwiftUI

struct CanvasView: View {
    @ObservedObject var documentState: DocumentState
    @StateObject private var toolManager = ToolManager.shared

    @State private var dragOffset: CGSize = .zero
    @GestureState private var magnificationAmount: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(nsColor: .controlBackgroundColor)

                // Grid (if enabled)
                if documentState.showGrid {
                    GridView(
                        gridSize: documentState.document.canvas.gridSize,
                        zoomLevel: documentState.zoomLevel
                    )
                }

                // Hoop outline (if enabled)
                if documentState.showHoop {
                    HoopView(
                        hoopSize: documentState.document.canvas.hoopSize,
                        zoomLevel: documentState.zoomLevel
                    )
                }

                // Layers
                ForEach(documentState.document.layers.filter { $0.isVisible }) { layer in
                    LayerView(layer: layer, zoomLevel: documentState.zoomLevel)
                }

                // Overlay for current tool
                ToolOverlay(tool: toolManager.selectedTool)
            }
            .scaleEffect(documentState.zoomLevel)
            .offset(
                x: documentState.canvasOffset.x + dragOffset.width,
                y: documentState.canvasOffset.y + dragOffset.height
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Pan with space bar or middle mouse
                        dragOffset = CGSize(
                            width: value.translation.width,
                            height: value.translation.height
                        )
                    }
                    .onEnded { _ in
                        documentState.canvasOffset.x += dragOffset.width
                        documentState.canvasOffset.y += dragOffset.height
                        dragOffset = .zero
                    }
            )
            .gesture(
                MagnificationGesture()
                    .updating($magnificationAmount) { value, state, _ in
                        state = value
                    }
                    .onEnded { value in
                        documentState.zoom(to: documentState.zoomLevel * value)
                    }
            )
            .onTapGesture { location in
                handleCanvasTap(at: location, in: geometry)
            }
        }
    }

    private func handleCanvasTap(at location: CGPoint, in geometry: GeometryProxy) {
        // Convert screen coordinates to canvas coordinates
        let canvasPoint = CGPoint(
            x: (location.x - geometry.size.width / 2 - documentState.canvasOffset.x) / documentState.zoomLevel,
            y: (location.y - geometry.size.height / 2 - documentState.canvasOffset.y) / documentState.zoomLevel
        )

        toolManager.selectedTool?.handleMouseDown(at: canvasPoint)
        toolManager.selectedTool?.handleMouseUp(at: canvasPoint)
    }
}

// MARK: - Grid View

struct GridView: View {
    let gridSize: Double
    let zoomLevel: Double

    var body: some View {
        Canvas { context, size in
            let scaledGridSize = gridSize * zoomLevel

            guard scaledGridSize > 2 else { return }

            let rows = Int(size.height / scaledGridSize) + 1
            let cols = Int(size.width / scaledGridSize) + 1

            context.stroke(
                Path { path in
                    // Vertical lines
                    for i in 0...cols {
                        let x = CGFloat(i) * scaledGridSize
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    }

                    // Horizontal lines
                    for i in 0...rows {
                        let y = CGFloat(i) * scaledGridSize
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }
                },
                with: .color(.gray.opacity(0.2)),
                lineWidth: 0.5
            )
        }
    }
}

// MARK: - Hoop View

struct HoopView: View {
    let hoopSize: EmbroideryCanvas.HoopSize
    let zoomLevel: Double

    var body: some View {
        let dimensions = hoopSize.dimensions
        let width = dimensions.width * zoomLevel
        let height = dimensions.height * zoomLevel

        Rectangle()
            .stroke(Color.accentColor, lineWidth: 2)
            .frame(width: width, height: height)
    }
}

// MARK: - Layer View

struct LayerView: View {
    let layer: EmbroideryLayer
    let zoomLevel: Double

    var body: some View {
        Canvas { context, size in
            // TODO: Render stitches
            // For now, just show placeholder
            for stitchGroup in layer.stitches {
                drawStitchGroup(stitchGroup, in: context, size: size)
            }
        }
        .opacity(layer.opacity)
    }

    private func drawStitchGroup(_ group: StitchGroup, in context: GraphicsContext, size: CGSize) {
        guard !group.points.isEmpty else { return }

        let path = Path { path in
            if let first = group.points.first {
                path.move(to: CGPoint(
                    x: first.x * zoomLevel + size.width / 2,
                    y: first.y * zoomLevel + size.height / 2
                ))

                for point in group.points.dropFirst() {
                    path.addLine(to: CGPoint(
                        x: point.x * zoomLevel + size.width / 2,
                        y: point.y * zoomLevel + size.height / 2
                    ))
                }
            }
        }

        context.stroke(
            path,
            with: .color(Color(group.color.nsColor)),
            lineWidth: 1.0
        )
    }
}

// MARK: - Tool Overlay

struct ToolOverlay: View {
    let tool: (any Tool)?

    var body: some View {
        // Placeholder for tool-specific overlays
        EmptyView()
    }
}
