//
//  ImprovedTopToolbar.swift
//  EmbroideryStudio
//
//  Enhanced toolbar with better visual hierarchy
//

import SwiftUI

extension TopToolbar {
    var improvedBody: some View {
        HStack(spacing: 0) {
            // Quick Tool Palette
            HStack(spacing: 2) {
                ForEach([
                    toolManager.availableTools.first(where: { $0.id == "selection" }),
                    toolManager.availableTools.first(where: { $0.id == "zoom" }),
                    toolManager.availableTools.first(where: { $0.id == "manual-digitize" }),
                    toolManager.availableTools.first(where: { $0.id == "text" })
                ].compactMap { $0 }, id: \.id) { tool in
                    ToolbarButton(
                        tool: tool,
                        isSelected: toolManager.selectedTool?.id == tool.id,
                        action: {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                toolManager.selectTool(tool)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            .cornerRadius(8)
            .padding(.leading, 8)

            Divider()
                .frame(height: 24)
                .padding(.horizontal, 12)

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
            .padding(.trailing, 8)
        }
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Toolbar Button

struct ToolbarButton: View {
    let tool: any Tool
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: tool.icon)
                .frame(width: 32, height: 32)
                .background(
                    Group {
                        if isSelected {
                            Color.accentColor
                        } else if isHovering {
                            Color.secondary.opacity(0.2)
                        } else {
                            Color.clear
                        }
                    }
                )
                .cornerRadius(6)
        }
        .buttonStyle(.borderless)
        .help(tool.tooltip)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
