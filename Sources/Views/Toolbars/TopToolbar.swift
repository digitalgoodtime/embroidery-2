//
//  TopToolbar.swift
//  EmbroideryStudio
//
//  Top toolbar with quick actions (Photoshop/Pixelmator Pro style with Liquid Glass)
//

import SwiftUI

struct TopToolbar: View {
    @ObservedObject var documentState: DocumentState

    var body: some View {
        HStack(spacing: 0) {
            // Zoom Controls
            HStack(spacing: .spacing1) {
                Button(action: documentState.zoomOut) {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.system(size: .iconSmall + 1))
                        .frame(width: .spacing6 + .spacing0_5, height: .spacing6 + .spacing0_5)
                }
                .buttonStyle(.borderless)
                .help("Zoom Out (⌘-)")
                .accessibilityLabel("Zoom out")

                Button(action: documentState.zoomToFit) {
                    Text("\(Int(documentState.zoomLevel * 100))%")
                        .font(.monoMedium)
                        .frame(minWidth: .spacing12 + .spacing1)
                }
                .buttonStyle(.borderless)
                .help("Zoom to Fit (Click)")
                .accessibilityLabel("Zoom level \(Int(documentState.zoomLevel * 100)) percent")
                .accessibilityHint("Tap to zoom to fit")

                Button(action: documentState.zoomIn) {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.system(size: .iconSmall + 1))
                        .frame(width: .spacing6 + .spacing0_5, height: .spacing6 + .spacing0_5)
                }
                .buttonStyle(.borderless)
                .help("Zoom In (⌘+)")
                .accessibilityLabel("Zoom in")

                Divider()
                    .frame(height: .spacing4 + .spacing0_5)
                    .padding(.horizontal, .spacing1)

                Button(action: documentState.zoomToFit) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: .iconSmall))
                        .frame(width: .spacing6 + .spacing0_5, height: .spacing6 + .spacing0_5)
                }
                .buttonStyle(.borderless)
                .help("Zoom to Fit (⌘0)")
                .accessibilityLabel("Zoom to fit")
            }
            .padding(.horizontal, .spacing1_5)
            .padding(.vertical, .spacing1)
            .background(Color.surfaceSecondary.opacity(.opacityMediumLight))
            .cornerRadius(.radiusSmall)
            .padding(.leading, .spacing3)

            Divider()
                .frame(height: .spacing6)
                .padding(.horizontal, .spacing3)

            // View Options
            HStack(spacing: .spacing0_5) {
                Toggle(isOn: $documentState.showGrid) {
                    Image(systemName: "grid")
                        .font(.system(size: .iconMediumSmall))
                        .frame(width: .spacing7 + .spacing0_5, height: .spacing7)
                }
                .toggleStyle(.button)
                .buttonStyle(.borderless)
                .help("Toggle Grid (⌘')")
                .accessibilityLabel("Toggle grid")
                .accessibilityValue(documentState.showGrid ? "On" : "Off")

                Toggle(isOn: $documentState.showHoop) {
                    Image(systemName: "circle.dashed")
                        .font(.system(size: .iconMediumSmall))
                        .frame(width: .spacing7 + .spacing0_5, height: .spacing7)
                }
                .toggleStyle(.button)
                .buttonStyle(.borderless)
                .help("Toggle Hoop (⌘H)")
                .accessibilityLabel("Toggle hoop")
                .accessibilityValue(documentState.showHoop ? "On" : "Off")

                Toggle(isOn: $documentState.showRulers) {
                    Image(systemName: "ruler")
                        .font(.system(size: .iconMediumSmall))
                        .frame(width: .spacing7 + .spacing0_5, height: .spacing7)
                }
                .toggleStyle(.button)
                .buttonStyle(.borderless)
                .help("Toggle Rulers (⌘R)")
                .accessibilityLabel("Toggle rulers")
                .accessibilityValue(documentState.showRulers ? "On" : "Off")
            }

            Spacer()

            // Document Info
            HStack(spacing: .spacing2) {
                Image(systemName: "thread.fill")
                    .font(.system(size: .iconTiny + 1))
                    .foregroundColor(.accentHigh)
                Text("\(documentState.totalStitchCount)")
                    .font(.monoMedium)
                    .foregroundColor(.textPrimary.opacity(.opacitySecondary))
                Text("stitches")
                    .font(.captionSmall)
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, .spacing2_5)
            .padding(.vertical, .spacing1)
            .background(Color.surfaceSecondary.opacity(.opacityMediumLight))
            .cornerRadius(.radiusSmall)
            .padding(.trailing, .spacing3)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(documentState.totalStitchCount) stitches in document")
        }
        .padding(.vertical, .spacing1_5)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Status Bar

struct StatusBar: View {
    @ObservedObject var documentState: DocumentState
    @StateObject private var toolManager = ToolManager.shared

    var body: some View {
        HStack(spacing: .spacing3_5) {
            // Current tool
            if let tool = toolManager.selectedTool {
                HStack(spacing: .spacing1_5) {
                    Image(systemName: tool.icon)
                        .font(.system(size: .iconSmall))
                        .foregroundColor(.accentColor)
                    Text(tool.name)
                        .font(.roundedMedium)
                        .foregroundColor(.textPrimary.opacity(.opacityHigh))
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Current tool: \(tool.name)")
            }

            Divider()
                .frame(height: .spacing4)

            // Cursor position / selection info
            HStack(spacing: .spacing1_5 - 1) {
                Image(systemName: "location.fill")
                    .font(.system(size: .iconTiny))
                    .foregroundColor(.textSecondary.opacity(.opacitySecondary))
                Text("Ready")
                    .font(.captionSmall)
                    .foregroundColor(.textSecondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Status: Ready")

            Spacer()

            // Layer info
            if let selectedID = documentState.selectedLayerID,
               let layer = documentState.document.layers.first(where: { $0.id == selectedID }) {
                HStack(spacing: .spacing1_5) {
                    Image(systemName: layer.isVisible ? "eye.fill" : "eye.slash")
                        .font(.system(size: .iconTiny + 1))
                        .foregroundColor(layer.isVisible ? Color.statusVisible : Color.statusHidden)
                    Text(layer.name)
                        .font(.roundedMedium)
                        .foregroundColor(.textPrimary.opacity(.opacityHigh))

                    if layer.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: .iconTiny + 1))
                            .foregroundColor(.statusLocked)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Selected layer: \(layer.name), \(layer.isVisible ? "visible" : "hidden")\(layer.isLocked ? ", locked" : "")")
            } else {
                Text("No layer selected")
                    .font(.captionSmall)
                    .foregroundColor(.textSecondary.opacity(.opacityMuted))
                    .accessibilityLabel("No layer selected")
            }
        }
        .padding(.horizontal, .spacing3_5)
        .padding(.vertical, .spacing1)
        .background(
            LinearGradient(
                colors: [
                    Color.surfacePrimary.opacity(.opacityNearFull),
                    Color.surfaceSecondary.opacity(.opacityNearFull)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.borderDefault.opacity(.opacityDisabled))
                .frame(height: .lineHairline)
        }
    }
}
