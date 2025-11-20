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
            .padding()

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
        VStack(alignment: .leading, spacing: 16) {
            // Tool-specific properties
            if let tool = toolManager.selectedTool {
                GroupBox(label: Text(tool.name).font(.headline)) {
                    toolPropertiesView(for: tool)
                        .padding(8)
                }
            }

            // Canvas Properties
            GroupBox(label: Text("Canvas").font(.headline)) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Hoop Size:")
                        Spacer()
                        Picker("", selection: $documentState.document.canvas.hoopSize) {
                            ForEach(EmbroideryCanvas.HoopSize.allCases, id: \.self) { size in
                                Text(size.rawValue).tag(size)
                            }
                        }
                        .frame(width: 120)
                    }

                    Toggle("Show Grid", isOn: $documentState.showGrid)
                    Toggle("Show Hoop", isOn: $documentState.showHoop)
                    Toggle("Show Rulers", isOn: $documentState.showRulers)
                    Toggle("Snap to Grid", isOn: $documentState.snapToGrid)
                }
                .padding(8)
            }

            // Stitch Properties
            GroupBox(label: Text("Stitch Settings").font(.headline)) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Density:")
                        Spacer()
                        Text("4.0 st/mm")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Thread Color:")
                        Spacer()
                        ColorPicker("", selection: .constant(Color.red))
                            .labelsHidden()
                    }

                    Divider()

                    Text("Fabric Assist: Auto")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(8)
            }

            Spacer()
        }
        .padding()
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Transform")
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            HStack {
                Text("Position:")
                Spacer()
                Text("X: 0  Y: 0")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("Size:")
                Spacer()
                Text("W: 0  H: 0")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("Rotation:")
                Spacer()
                Text("0°")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct DigitizerToolProperties: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Digitize Mode")
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            Picker("Stitch Type:", selection: .constant(StitchType.running)) {
                Text("Running").tag(StitchType.running)
                Text("Satin").tag(StitchType.satin)
                Text("Fill").tag(StitchType.fill)
            }

            HStack {
                Text("Density:")
                Slider(value: .constant(4.0), in: 1...10)
                Text("4.0")
                    .font(.caption.monospacedDigit())
                    .frame(width: 40, alignment: .trailing)
            }
        }
    }
}

struct TextToolProperties: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Font Settings")
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            Picker("Font:", selection: .constant("Default")) {
                Text("Default").tag("Default")
                Text("Script").tag("Script")
                Text("Block").tag("Block")
            }

            HStack {
                Text("Size:")
                Slider(value: .constant(12.0), in: 8...72)
                Text("12")
                    .font(.caption.monospacedDigit())
                    .frame(width: 30, alignment: .trailing)
            }
        }
    }
}

// MARK: - Stitch Player Panel

struct StitchPlayerPanelView: View {
    @ObservedObject var documentState: DocumentState

    var body: some View {
        VStack(spacing: 16) {
            // Preview area
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.1))
                .frame(height: 200)
                .overlay {
                    VStack {
                        Image(systemName: "figure.wave.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Stitch Preview")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

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
            GroupBox(label: Text("Statistics").font(.headline)) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Total Stitches:")
                        Spacer()
                        Text("\(documentState.totalStitchCount)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Colors:")
                        Spacer()
                        Text("\(documentState.document.metadata.colorCount)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Est. Time:")
                        Spacer()
                        Text("-- min")
                            .foregroundColor(.secondary)
                    }
                }
                .font(.caption)
                .padding(8)
            }

            Spacer()
        }
        .padding()
    }
}
