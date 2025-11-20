//
//  PropertiesSidebar.swift
//  EmbroideryStudio
//
//  Contextual properties panel (right side)
//

import SwiftUI

struct PropertiesSidebar: View {
    @ObservedObject var documentState: DocumentState
    @StateObject private var toolManager = ToolManager.shared

    @State private var selectedTab: SidebarTab = .properties

    enum SidebarTab: String, CaseIterable {
        case properties = "Properties"
        case stitch = "Stitch Player"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tab Picker
            Picker("", selection: $selectedTab) {
                ForEach(SidebarTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()

            // Tab Content
            ScrollView {
                switch selectedTab {
                case .properties:
                    PropertiesPanelView(documentState: documentState)
                case .stitch:
                    StitchPlayerPanelView(documentState: documentState)
                }
            }
        }
    }
}

// MARK: - Properties Panel

struct PropertiesPanelView: View {
    @ObservedObject var documentState: DocumentState
    @StateObject private var toolManager = ToolManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Tool-specific properties
            if let tool = toolManager.selectedTool {
                VStack(alignment: .leading, spacing: 8) {
                    Text(tool.name)
                        .font(.system(.subheadline, weight: .semibold))
                        .foregroundColor(.primary)

                    VStack(alignment: .leading, spacing: 10) {
                        toolPropertiesView(for: tool)
                    }
                    .padding(12)
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
                    .cornerRadius(6)
                }
            }

            // Canvas Properties
            VStack(alignment: .leading, spacing: 8) {
                Text("Canvas")
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundColor(.primary)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Hoop Size:")
                            .font(.system(.caption, weight: .medium))
                        Spacer()
                        Picker("", selection: $documentState.document.canvas.hoopSize) {
                            ForEach(EmbroideryCanvas.HoopSize.allCases, id: \.self) { size in
                                Text(size.rawValue).tag(size)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 110)
                    }

                    Divider()
                        .padding(.vertical, 2)

                    Toggle("Show Grid", isOn: $documentState.showGrid)
                        .font(.system(.caption, weight: .medium))
                    Toggle("Show Hoop", isOn: $documentState.showHoop)
                        .font(.system(.caption, weight: .medium))
                    Toggle("Show Rulers", isOn: $documentState.showRulers)
                        .font(.system(.caption, weight: .medium))
                    Toggle("Snap to Grid", isOn: $documentState.snapToGrid)
                        .font(.system(.caption, weight: .medium))
                }
                .padding(12)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
                .cornerRadius(6)
            }

            // Stitch Properties
            VStack(alignment: .leading, spacing: 8) {
                Text("Stitch Settings")
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundColor(.primary)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Density:")
                            .font(.system(.caption, weight: .medium))
                        Spacer()
                        Text("4.0 st/mm")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Thread Color:")
                            .font(.system(.caption, weight: .medium))
                        Spacer()
                        ColorPicker("", selection: .constant(Color.red))
                            .labelsHidden()
                    }

                    Divider()
                        .padding(.vertical, 2)

                    HStack {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                            .foregroundColor(.accentColor)
                        Text("Fabric Assist: Auto")
                            .font(.system(.caption2))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(12)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
                .cornerRadius(6)
            }

            Spacer()
        }
        .padding(12)
    }

    @ViewBuilder
    private func toolPropertiesView(for tool: any Tool) -> some View {
        switch tool.id {
        case "selection":
            SelectionToolProperties()
        case "manual-digitize":
            DigitizerToolProperties()
        case "text":
            TextToolProperties()
        default:
            Text("No properties available")
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
}

// MARK: - Tool-Specific Properties

struct SelectionToolProperties: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Position:")
                    .font(.system(.caption, weight: .medium))
                Spacer()
                Text("X: 0  Y: 0")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("Size:")
                    .font(.system(.caption, weight: .medium))
                Spacer()
                Text("W: 0  H: 0")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("Rotation:")
                    .font(.system(.caption, weight: .medium))
                Spacer()
                Text("0°")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct DigitizerToolProperties: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Stitch Type:")
                    .font(.system(.caption, weight: .medium))

                Picker("", selection: .constant(StitchType.running)) {
                    Text("Running").tag(StitchType.running)
                    Text("Satin").tag(StitchType.satin)
                    Text("Fill").tag(StitchType.fill)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            Divider()
                .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Density:")
                        .font(.system(.caption, weight: .medium))
                    Spacer()
                    Text("4.0 st/mm")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Slider(value: .constant(4.0), in: 1...10)
                    .controlSize(.small)
                    .tint(.accentColor)
            }
        }
    }
}

struct TextToolProperties: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Font:")
                    .font(.system(.caption, weight: .medium))

                Picker("", selection: .constant("Default")) {
                    Text("Default").tag("Default")
                    Text("Script").tag("Script")
                    Text("Block").tag("Block")
                }
                .labelsHidden()
            }

            Divider()
                .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Size:")
                        .font(.system(.caption, weight: .medium))
                    Spacer()
                    Text("12 pt")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Slider(value: .constant(12.0), in: 8...72)
                    .controlSize(.small)
                    .tint(.accentColor)
            }
        }
    }
}

// MARK: - Stitch Player Panel

struct StitchPlayerPanelView: View {
    @ObservedObject var documentState: DocumentState

    var body: some View {
        VStack(spacing: 14) {
            // Preview area
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color.secondary.opacity(0.08), Color.secondary.opacity(0.12)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 200)
                .overlay {
                    VStack(spacing: 12) {
                        Image(systemName: "figure.wave.circle")
                            .font(.system(size: 52))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("Stitch Preview")
                            .font(.system(.caption, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color(nsColor: .separatorColor), lineWidth: 1)
                )

            // Playback controls
            VStack(spacing: 12) {
                // Progress bar
                VStack(spacing: 4) {
                    Slider(
                        value: Binding(
                            get: { Double(documentState.currentStitchIndex) },
                            set: { documentState.currentStitchIndex = Int($0) }
                        ),
                        in: 0...Double(max(1, documentState.totalStitchCount - 1))
                    )

                    HStack {
                        Text("Stitch \(documentState.currentStitchIndex + 1)")
                            .font(.caption2)
                        Spacer()
                        Text("\(documentState.totalStitchCount) total")
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                }

                // Buttons
                HStack(spacing: 12) {
                    Button(action: documentState.stepBackward) {
                        Image(systemName: "backward.frame.fill")
                    }
                    .disabled(documentState.currentStitchIndex == 0)

                    Button(action: {
                        if documentState.isPlaying {
                            documentState.pauseStitches()
                        } else {
                            documentState.playStitches()
                        }
                    }) {
                        Image(systemName: documentState.isPlaying ? "pause.fill" : "play.fill")
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: documentState.stepForward) {
                        Image(systemName: "forward.frame.fill")
                    }
                    .disabled(documentState.currentStitchIndex >= documentState.totalStitchCount - 1)

                    Button(action: documentState.stopStitches) {
                        Image(systemName: "stop.fill")
                    }
                }

                // Speed control
                HStack {
                    Text("Speed:")
                    Slider(value: $documentState.playbackSpeed, in: 0.1...5.0)
                    Text("\(String(format: "%.1f", documentState.playbackSpeed))x")
                        .frame(width: 40, alignment: .trailing)
                        .font(.caption)
                }
            }

            // Statistics
            VStack(alignment: .leading, spacing: 8) {
                Text("Statistics")
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundColor(.primary)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Total Stitches:")
                            .font(.system(.caption, weight: .medium))
                        Spacer()
                        Text("\(documentState.totalStitchCount)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Colors:")
                            .font(.system(.caption, weight: .medium))
                        Spacer()
                        Text("\(documentState.document.metadata.colorCount)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Est. Time:")
                            .font(.system(.caption, weight: .medium))
                        Spacer()
                        Text("-- min")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(12)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
                .cornerRadius(6)
            }

            Spacer()
        }
        .padding(12)
    }
}
