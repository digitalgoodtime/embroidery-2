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
            HStack(spacing: 4) {
                Button(action: documentState.zoomOut) {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.system(size: 13))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.borderless)
                .help("Zoom Out (⌘-)")

                Button(action: {}) {
                    Text("\(Int(documentState.zoomLevel * 100))%")
                        .font(.system(.caption, design: .monospaced, weight: .medium))
                        .frame(minWidth: 52)
                }
                .buttonStyle(.borderless)
                .help("Current Zoom Level")

                Button(action: documentState.zoomIn) {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.system(size: 13))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.borderless)
                .help("Zoom In (⌘+)")

                Divider()
                    .frame(height: 18)
                    .padding(.horizontal, 4)

                Button(action: documentState.zoomToFit) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 12))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.borderless)
                .help("Zoom to Fit (⌘0)")
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.25))
            .cornerRadius(5)
            .padding(.leading, 12)

            Divider()
                .frame(height: 24)
                .padding(.horizontal, 12)

            // View Options
            HStack(spacing: 2) {
                Toggle(isOn: $documentState.showGrid) {
                    Image(systemName: "grid")
                        .font(.system(size: 14))
                        .frame(width: 30, height: 28)
                }
                .toggleStyle(.button)
                .buttonStyle(.borderless)
                .help("Toggle Grid (⌘')")

                Toggle(isOn: $documentState.showHoop) {
                    Image(systemName: "circle.dashed")
                        .font(.system(size: 14))
                        .frame(width: 30, height: 28)
                }
                .toggleStyle(.button)
                .buttonStyle(.borderless)
                .help("Toggle Hoop (⌘H)")

                Toggle(isOn: $documentState.showRulers) {
                    Image(systemName: "ruler")
                        .font(.system(size: 14))
                        .frame(width: 30, height: 28)
                }
                .toggleStyle(.button)
                .buttonStyle(.borderless)
                .help("Toggle Rulers (⌘R)")
            }

            Spacer()

            // Document Info
            HStack(spacing: 8) {
                Image(systemName: "thread.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.accentColor.opacity(0.8))
                Text("\(documentState.totalStitchCount)")
                    .font(.system(.caption, design: .monospaced, weight: .medium))
                    .foregroundColor(.primary.opacity(0.7))
                Text("stitches")
                    .font(.system(.caption2))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.25))
            .cornerRadius(5)
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
        HStack(spacing: 14) {
            // Current tool
            if let tool = toolManager.selectedTool {
                HStack(spacing: 6) {
                    Image(systemName: tool.icon)
                        .font(.system(size: 12))
                        .foregroundColor(.accentColor)
                    Text(tool.name)
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundColor(.primary.opacity(0.8))
                }
            }

            Divider()
                .frame(height: 16)

            // Cursor position / selection info
            HStack(spacing: 5) {
                Image(systemName: "location.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.7))
                Text("Ready")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Layer info
            if let selectedID = documentState.selectedLayerID,
               let layer = documentState.document.layers.first(where: { $0.id == selectedID }) {
                HStack(spacing: 6) {
                    Image(systemName: layer.isVisible ? "eye.fill" : "eye.slash")
                        .font(.system(size: 11))
                        .foregroundColor(layer.isVisible ? .secondary.opacity(0.7) : .red.opacity(0.8))
                    Text(layer.name)
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundColor(.primary.opacity(0.8))

                    if layer.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.orange.opacity(0.9))
                    }
                }
            } else {
                Text("No layer selected")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.6))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .background(
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor).opacity(0.98),
                    Color(nsColor: .controlBackgroundColor).opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color(nsColor: .separatorColor).opacity(0.5))
                .frame(height: 0.5)
        }
    }
}
