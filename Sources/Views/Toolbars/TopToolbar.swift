//
//  TopToolbar.swift
//  EmbroideryStudio
//
//  Top toolbar with quick actions (Photoshop/Pixelmator Pro style)
//

import SwiftUI

struct TopToolbar: View {
    @ObservedObject var documentState: DocumentState

    var body: some View {
        HStack(spacing: 0) {
            // Zoom Controls
            HStack(spacing: 6) {
                Button(action: documentState.zoomOut) {
                    Image(systemName: "minus.magnifyingglass")
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.borderless)
                .help("Zoom Out (⌘-)")

                Button(action: {}) {
                    Text("\(Int(documentState.zoomLevel * 100))%")
                        .font(.system(.caption, design: .monospaced))
                        .frame(minWidth: 50)
                }
                .buttonStyle(.borderless)
                .help("Current Zoom Level")

                Button(action: documentState.zoomIn) {
                    Image(systemName: "plus.magnifyingglass")
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.borderless)
                .help("Zoom In (⌘+)")

                Button(action: documentState.zoomToFit) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.borderless)
                .help("Zoom to Fit (⌘0)")
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
            .cornerRadius(6)
            .padding(.leading, 12)

            Divider()
                .frame(height: 24)
                .padding(.horizontal, 12)

            // View Options
            HStack(spacing: 4) {
                Toggle(isOn: $documentState.showGrid) {
                    Image(systemName: "grid")
                        .frame(width: 28, height: 28)
                }
                .toggleStyle(.button)
                .help("Toggle Grid (⌘')")

                Toggle(isOn: $documentState.showHoop) {
                    Image(systemName: "circle.dashed")
                        .frame(width: 28, height: 28)
                }
                .toggleStyle(.button)
                .help("Toggle Hoop (⌘H)")

                Toggle(isOn: $documentState.showRulers) {
                    Image(systemName: "ruler")
                        .frame(width: 28, height: 28)
                }
                .toggleStyle(.button)
                .help("Toggle Rulers (⌘R)")
            }

            Spacer()

            // Document Info
            HStack(spacing: 12) {
                Label {
                    Text("\(documentState.totalStitchCount)")
                        .font(.system(.caption, design: .monospaced))
                } icon: {
                    Image(systemName: "thread.fill")
                        .foregroundColor(.secondary)
                }
                .foregroundColor(.secondary)
            }
            .padding(.trailing, 12)
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
        HStack(spacing: 16) {
            // Current tool
            if let tool = toolManager.selectedTool {
                HStack(spacing: 6) {
                    Image(systemName: tool.icon)
                        .foregroundColor(.accentColor)
                    Text(tool.name)
                        .font(.system(.caption, design: .rounded))
                }
            }

            Divider()
                .frame(height: 16)

            // Cursor position / selection info
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Text("Ready")
                    .font(.caption)
            }
            .foregroundColor(.secondary)

            Spacer()

            // Layer info
            if let selectedID = documentState.selectedLayerID,
               let layer = documentState.document.layers.first(where: { $0.id == selectedID }) {
                HStack(spacing: 6) {
                    Image(systemName: layer.isVisible ? "eye.fill" : "eye.slash")
                        .font(.system(size: 10))
                        .foregroundColor(layer.isVisible ? .secondary : .red)
                    Text(layer.name)
                        .font(.system(.caption, design: .rounded))

                    if layer.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                    }
                }
                .foregroundColor(.secondary)
            } else {
                Text("No layer selected")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
        .padding(.horizontal, 12)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.95))
    }
}
