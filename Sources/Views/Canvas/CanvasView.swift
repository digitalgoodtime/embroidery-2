//
//  CanvasView.swift
//  EmbroideryStudio
//
//  Main canvas view for displaying and editing embroidery designs with liquid glass polish
//

import SwiftUI

struct CanvasView: View {
    @ObservedObject var documentState: DocumentState
    @StateObject private var toolManager = ToolManager.shared

    @State private var dragOffset: CGSize = .zero
    @GestureState private var magnificationAmount: CGFloat = 1.0
    @State private var showTextDialog: Bool = false
    @State private var textDialogPosition: CGPoint = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.surfaceCanvas

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
                    LayerView(
                        layer: layer,
                        zoomLevel: documentState.zoomLevel,
                        showStitchPoints: documentState.showStitchPoints,
                        showThreadPath: documentState.showThreadPath,
                        stitchPointSize: documentState.stitchPointSize
                    )
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
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Embroidery canvas")
        .accessibilityHint("Drag to pan, pinch to zoom, tap to use current tool")
        .sheet(isPresented: $showTextDialog) {
            TextInputDialog(
                position: textDialogPosition,
                defaultColor: getCurrentThreadColor(),
                onConfirm: { textObject in
                    documentState.addText(textObject)
                }
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .showTextInputDialog)) { notification in
            if let positionValue = notification.userInfo?[TextToolNotificationKey.position] as? NSValue {
                textDialogPosition = positionValue.pointValue
                showTextDialog = true
            }
        }
    }

    private func getCurrentThreadColor() -> CodableColor {
        // Try to get the last used color from the current layer
        if let selectedID = documentState.selectedLayerID,
           let layer = documentState.document.layers.first(where: { $0.id == selectedID }),
           let lastStitch = layer.stitches.last {
            return lastStitch.color
        }

        // Default to black
        return CodableColor(.black)
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
                with: .color(.textPrimary.opacity(.opacitySubtle)),
                lineWidth: .lineHairline
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
                    with: .color(.textPrimary.opacity(.opacityMediumLight)),
                    lineWidth: .lineStandard - 0.25
                )
            }
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

        ZStack {
            // Subtle outer glow
            RoundedRectangle(cornerRadius: .radiusMedium)
                .stroke(Color.accentLightMedium, lineWidth: .lineVeryStrong)
                .frame(width: width + .spacing1_5, height: height + .spacing1_5)
                .blur(radius: .spacing0_5 + 1)

            // Main hoop outline
            RoundedRectangle(cornerRadius: .radiusSmall)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.accentHigh,
                            Color.accentMuted
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: .lineEmphasis, dash: [10, 5])
                )
                .frame(width: width, height: height)

            // Hoop size label
            VStack {
                Spacer()
                HStack(spacing: .spacing1) {
                    Image(systemName: "circle.dashed")
                        .font(.system(size: .iconSmall - 1))
                        .foregroundColor(.accentHigh)
                    Text(hoopSize.rawValue)
                        .font(.captionSmallMedium)
                        .foregroundColor(.textPrimary.opacity(.opacitySecondary))
                }
                .padding(.horizontal, .spacing2)
                .padding(.vertical, .spacing1)
                .background(.ultraThinMaterial)
                .cornerRadius(.radiusXSmall)
                .shadowSubtle()
                .offset(y: height / 2 + .spacing5)
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Layer View

struct LayerView: View {
    let layer: EmbroideryLayer
    let zoomLevel: Double
    let showStitchPoints: Bool
    let showThreadPath: Bool
    let stitchPointSize: Double

    var body: some View {
        Canvas { context, size in
            for stitchGroup in layer.stitches {
                drawStitchGroup(stitchGroup, in: context, size: size)
            }
        }
        .opacity(layer.opacity)
    }

    private func drawStitchGroup(_ group: StitchGroup, in context: GraphicsContext, size: CGSize) {
        guard !group.points.isEmpty else { return }

        let color = Color(group.color.nsColor)

        // Draw thread path (connecting lines)
        if showThreadPath || !showStitchPoints {
            let path = Path { path in
                if let first = group.points.first {
                    path.move(to: transformPoint(first, size: size))

                    for point in group.points.dropFirst() {
                        path.addLine(to: transformPoint(point, size: size))
                    }
                }
            }

            context.stroke(
                path,
                with: .color(color),
                lineWidth: showStitchPoints ? .lineHairline : .lineStandard
            )
        }

        // Draw stitch points
        if showStitchPoints {
            for point in group.points {
                let center = transformPoint(point, size: size)

                // Draw stitch point as small circle
                let pointPath = Path { path in
                    path.addEllipse(in: CGRect(
                        x: center.x - CGFloat(stitchPointSize),
                        y: center.y - CGFloat(stitchPointSize),
                        width: CGFloat(stitchPointSize * 2),
                        height: CGFloat(stitchPointSize * 2)
                    ))
                }

                // Fill with color
                context.fill(pointPath, with: .color(color))

                // Add subtle border for visibility
                context.stroke(
                    pointPath,
                    with: .color(.white.opacity(0.5)),
                    lineWidth: 0.5
                )
            }
        }
    }

    private func transformPoint(_ point: StitchPoint, size: CGSize) -> CGPoint {
        CGPoint(
            x: point.x * zoomLevel + size.width / 2,
            y: point.y * zoomLevel + size.height / 2
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
