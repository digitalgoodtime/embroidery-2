//
//  ToolsSidebar.swift
//  EmbroideryStudio
//
//  Tools sidebar (right side, Pixelmator Pro style)
//

import SwiftUI

struct ToolsSidebar: View {
    @ObservedObject var documentState: DocumentState
    @StateObject private var toolManager = ToolManager.shared

    @State private var selectedTab: SidebarTab = .tools

    enum SidebarTab: String, CaseIterable {
        case tools = "Tools"
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
                case .tools:
                    ToolsPanelView(toolManager: toolManager)
                case .properties:
                    PropertiesPanelView(documentState: documentState)
                case .stitch:
                    StitchPlayerPanelView(documentState: documentState)
                }
            }
        }
    }
}

// MARK: - Tools Panel

struct ToolsPanelView: View {
    @ObservedObject var toolManager: ToolManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(ToolCategory.allCases, id: \.self) { category in
                let tools = toolManager.tools(for: category)

                if !tools.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)

                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 60), spacing: 8)
                        ], spacing: 8) {
                            ForEach(tools, id: \.id) { tool in
                                ToolButton(
                                    tool: tool,
                                    isSelected: toolManager.selectedTool?.id == tool.id,
                                    action: { toolManager.selectTool(tool) }
                                )
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct ToolButton: View {
    let tool: any Tool
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: tool.icon)
                .font(.title3)
                .frame(width: 60, height: 44)
                .background(isSelected ? Color.accentColor : (isHovering ? Color.secondary.opacity(0.1) : Color.clear))
                .cornerRadius(8)

            Text(tool.name)
                .font(.caption2)
                .lineLimit(1)
        }
        .frame(width: 60)
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
        .onHover { hovering in
            isHovering = hovering
        }
        .help(tool.tooltip)
    }
}

// MARK: - Properties Panel

struct PropertiesPanelView: View {
    @ObservedObject var documentState: DocumentState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
