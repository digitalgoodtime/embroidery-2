//
//  TopToolbar.swift
//  EmbroideryStudio
//
//  Top toolbar with quick actions (Photoshop/Pixelmator Pro style)
//

import SwiftUI

struct TopToolbar: View {
    @ObservedObject var documentState: DocumentState
    @StateObject private var toolManager = ToolManager.shared

    var body: some View {
        HStack(spacing: 16) {
            // Quick Tool Palette (Photoshop-style)
            HStack(spacing: 4) {
                ForEach([
                    toolManager.availableTools.first(where: { $0.id == "selection" }),
                    toolManager.availableTools.first(where: { $0.id == "zoom" }),
                    toolManager.availableTools.first(where: { $0.id == "manual-digitize" }),
                    toolManager.availableTools.first(where: { $0.id == "text" })
                ].compactMap { $0 }, id: \.id) { tool in
                    Button(action: { toolManager.selectTool(tool) }) {
                        Image(systemName: tool.icon)
                            .frame(width: 32, height: 32)
                            .background(
                                toolManager.selectedTool?.id == tool.id
                                    ? Color.accentColor
                                    : Color.clear
                            )
                            .cornerRadius(6)
                    }
                    .buttonStyle(.borderless)
                    .help(tool.tooltip)
                }
            }
            .padding(.leading, 8)

            Divider()
                .frame(height: 24)

            // Zoom Controls
            HStack(spacing: 8) {
                Button(action: documentState.zoomOut) {
                    Image(systemName: "minus.magnifyingglass")
                }
                .help("Zoom Out")

                Text("\(Int(documentState.zoomLevel * 100))%")
                    .font(.system(.body, design: .monospaced))
                    .frame(minWidth: 50)

                Button(action: documentState.zoomIn) {
                    Image(systemName: "plus.magnifyingglass")
                }
                .help("Zoom In")

                Button(action: documentState.zoomToFit) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                }
                .help("Zoom to Fit")
            }
            .buttonStyle(.borderless)

            Divider()
                .frame(height: 24)

            // View Options
            HStack(spacing: 8) {
                Toggle(isOn: $documentState.showGrid) {
                    Image(systemName: "grid")
                }
                .toggleStyle(.button)
                .help("Toggle Grid")

                Toggle(isOn: $documentState.showHoop) {
                    Image(systemName: "circle.dashed")
                }
                .toggleStyle(.button)
                .help("Toggle Hoop")

                Toggle(isOn: $documentState.showRulers) {
                    Image(systemName: "ruler")
                }
                .toggleStyle(.button)
                .help("Toggle Rulers")
            }

            Spacer()

            // Document Info
            HStack(spacing: 8) {
                Image(systemName: "thread.fill")
                Text("\(documentState.totalStitchCount) stitches")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()
                .frame(height: 24)

            // Quick Actions
            HStack(spacing: 4) {
                Button(action: { /* TODO: Export */ }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .help("Export Design")
            }
            .padding(.trailing, 8)
        }
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Status Bar

struct StatusBar: View {
    @ObservedObject var documentState: DocumentState
    @StateObject private var toolManager = ToolManager.shared

    var body: some View {
        HStack {
            // Current tool
            if let tool = toolManager.selectedTool {
                HStack(spacing: 6) {
                    Image(systemName: tool.icon)
                    Text(tool.name)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()

            // Cursor position / selection info
            Text("Ready")
                .font(.caption)
                .foregroundColor(.secondary)

            Divider()
                .frame(height: 16)

            // Layer info
            if let selectedID = documentState.selectedLayerID,
               let layer = documentState.document.layers.first(where: { $0.id == selectedID }) {
                Text(layer.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("No layer selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
