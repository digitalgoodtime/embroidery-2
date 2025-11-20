//
//  PropertiesSidebar.swift
//  EmbroideryStudio
//
//  Contextual properties panel (right side) with liquid glass and collapsible sections
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
            .padding(.horizontal, .spacing3)
            .padding(.vertical, .spacing2_5)
            .background(Color.surfaceSecondary.opacity(.opacityLight))
            .accessibilityLabel("Properties panel tabs")

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
        VStack(alignment: .leading, spacing: .spacing3_5) {
            // Tool-specific properties
            if let tool = toolManager.selectedTool {
                CollapsibleSection(
                    title: tool.name,
                    icon: tool.icon,
                    isExpanded: true
                ) {
                    toolPropertiesView(for: tool)
                }
            }

            // Canvas Properties
            CollapsibleSection(
                title: "Canvas",
                icon: "square.on.square.dashed",
                isExpanded: true
            ) {
                VStack(alignment: .leading, spacing: .spacing2_5) {
                    HStack {
                        Text("Hoop Size:")
                            .font(.label)
                        Spacer()
                        Picker("", selection: $documentState.document.canvas.hoopSize) {
                            ForEach(EmbroideryCanvas.HoopSize.allCases, id: \.self) { size in
                                Text(size.rawValue).tag(size)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 110)
                    }

                    Toggle("Show Grid", isOn: $documentState.showGrid)
                        .font(.label)
                    Toggle("Show Hoop", isOn: $documentState.showHoop)
                        .font(.label)
                    Toggle("Show Rulers", isOn: $documentState.showRulers)
                        .font(.label)
                    Toggle("Snap to Grid", isOn: $documentState.snapToGrid)
                        .font(.label)
                }
            }

            // Stitch Properties
            CollapsibleSection(
                title: "Stitch Settings",
                icon: "thread.fill",
                isExpanded: true
            ) {
                VStack(alignment: .leading, spacing: .spacing2_5) {
                    HStack {
                        Text("Density:")
                            .font(.label)
                        Spacer()
                        Text("4.0 st/mm")
                            .font(.mono)
                            .foregroundColor(.textSecondary)
                    }

                    HStack {
                        Text("Thread Color:")
                            .font(.label)
                        Spacer()
                        ColorPicker("", selection: .constant(Color.red))
                            .labelsHidden()
                    }

                    HStack {
                        Image(systemName: "sparkles")
                            .font(.system(size: .iconTiny))
                            .foregroundColor(.accentColor)
                        Text("Fabric Assist: Auto")
                            .font(.captionSmall)
                            .foregroundColor(.textSecondary)
                    }
                }
            }

            Spacer()
        }
        .padding(.spacing3)
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
                .foregroundColor(.textSecondary)
                .font(.caption)
        }
    }
}

// MARK: - Collapsible Section Component

struct CollapsibleSection<Content: View>: View {
    let title: String
    let icon: String
    @State var isExpanded: Bool
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing2) {
            // Header
            Button(action: {
                withAnimation(.springQuick) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: .spacing2) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: .iconTiny, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .frame(width: .spacing3, height: .spacing3)
                        .animation(.springQuick, value: isExpanded)

                    Image(systemName: icon)
                        .font(.system(size: .iconSmall))
                        .foregroundColor(.accentColor)

                    Text(title)
                        .font(.headingSmall)
                        .foregroundColor(.textPrimary)

                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(title) section")
            .accessibilityHint(isExpanded ? "Expanded, double tap to collapse" : "Collapsed, double tap to expand")
            .accessibilityAddTraits(.isButton)

            // Content
            if isExpanded {
                VStack(alignment: .leading, spacing: .spacing2_5) {
                    content()
                }
                .padding(.spacing3)
                .background(Color.surfaceSecondary.opacity(.opacityMedium))
                .cornerRadius(.radiusMedium)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

// MARK: - Tool-Specific Properties

struct SelectionToolProperties: View {
    var body: some View {
        VStack(alignment: .leading, spacing: .spacing2_5) {
            HStack {
                Text("Position:")
                    .font(.label)
                Spacer()
                Text("X: 0  Y: 0")
                    .font(.mono)
                    .foregroundColor(.textSecondary)
            }

            HStack {
                Text("Size:")
                    .font(.label)
                Spacer()
                Text("W: 0  H: 0")
                    .font(.mono)
                    .foregroundColor(.textSecondary)
            }

            HStack {
                Text("Rotation:")
                    .font(.label)
                Spacer()
                Text("0°")
                    .font(.mono)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

struct DigitizerToolProperties: View {
    var body: some View {
        VStack(alignment: .leading, spacing: .spacing2_5) {
            VStack(alignment: .leading, spacing: .spacing1_5) {
                Text("Stitch Type:")
                    .font(.label)

                Picker("", selection: .constant(StitchType.running)) {
                    Text("Running").tag(StitchType.running)
                    Text("Satin").tag(StitchType.satin)
                    Text("Fill").tag(StitchType.fill)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            VStack(alignment: .leading, spacing: .spacing1_5) {
                HStack {
                    Text("Density:")
                        .font(.label)
                    Spacer()
                    Text("4.0 st/mm")
                        .font(.mono)
                        .foregroundColor(.textSecondary)
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
        VStack(alignment: .leading, spacing: .spacing2_5) {
            VStack(alignment: .leading, spacing: .spacing1_5) {
                Text("Font:")
                    .font(.label)

                Picker("", selection: .constant("Default")) {
                    Text("Default").tag("Default")
                    Text("Script").tag("Script")
                    Text("Block").tag("Block")
                }
                .labelsHidden()
            }

            VStack(alignment: .leading, spacing: .spacing1_5) {
                HStack {
                    Text("Size:")
                        .font(.label)
                    Spacer()
                    Text("12 pt")
                        .font(.mono)
                        .foregroundColor(.textSecondary)
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
        VStack(spacing: .spacing3_5) {
            // Preview area
            RoundedRectangle(cornerRadius: .radiusMedium)
                .fill(
                    LinearGradient(
                        colors: [Color.secondary.opacity(.opacitySubtle), Color.secondary.opacity(.opacityLightMedium)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 200)
                .overlay {
                    if documentState.totalStitchCount == 0 {
                        VStack(spacing: .spacing3) {
                            Image(systemName: "figure.wave.circle")
                                .font(.system(size: .iconHero))
                                .foregroundColor(.accentMedium)
                                .symbolRenderingMode(.hierarchical)
                            VStack(spacing: .spacing1) {
                                Text("No Stitches Yet")
                                    .font(.bodyEmphasis)
                                    .foregroundColor(.textPrimary.opacity(.opacitySecondary))
                                Text("Create a design to preview stitches")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    } else {
                        Text("Stitch Preview")
                            .font(.label)
                            .foregroundColor(.textSecondary)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: .radiusMedium)
                        .strokeBorder(Color.borderSubtle, lineWidth: .lineStandard)
                )
                .shadowLight()

            // Playback controls
            VStack(spacing: .spacing3) {
                // Progress bar
                VStack(spacing: .spacing1) {
                    Slider(
                        value: Binding(
                            get: { Double(documentState.currentStitchIndex) },
                            set: { documentState.currentStitchIndex = Int($0) }
                        ),
                        in: 0...Double(max(1, documentState.totalStitchCount - 1))
                    )
                    .tint(.accentColor)

                    HStack {
                        Text("Stitch \(documentState.currentStitchIndex + 1)")
                            .font(.captionSmall)
                        Spacer()
                        Text("\(documentState.totalStitchCount) total")
                            .font(.captionSmall)
                    }
                    .foregroundColor(.textSecondary)
                }

                // Buttons
                HStack(spacing: .spacing3) {
                    Button(action: documentState.stepBackward) {
                        Image(systemName: "backward.frame.fill")
                            .font(.system(size: .iconMedium))
                    }
                    .buttonStyle(.borderless)
                    .disabled(documentState.currentStitchIndex == 0)
                    .opacity(documentState.currentStitchIndex == 0 ? .opacityDisabled : 1)

                    Button(action: {
                        if documentState.isPlaying {
                            documentState.pauseStitches()
                        } else {
                            documentState.playStitches()
                        }
                    }) {
                        Image(systemName: documentState.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: .iconMediumLarge))
                            .frame(width: .spacing7 + .spacing0_5, height: .spacing7 + .spacing0_5)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button(action: documentState.stepForward) {
                        Image(systemName: "forward.frame.fill")
                            .font(.system(size: .iconMedium))
                    }
                    .buttonStyle(.borderless)
                    .disabled(documentState.currentStitchIndex >= documentState.totalStitchCount - 1)
                    .opacity(documentState.currentStitchIndex >= documentState.totalStitchCount - 1 ? .opacityDisabled : 1)

                    Button(action: documentState.stopStitches) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: .iconMedium))
                    }
                    .buttonStyle(.borderless)
                }

                // Speed control
                HStack(spacing: .spacing2) {
                    Text("Speed:")
                        .font(.label)
                    Slider(value: $documentState.playbackSpeed, in: 0.1...5.0)
                        .tint(.accentColor)
                    Text("\(String(format: "%.1f", documentState.playbackSpeed))x")
                        .font(.mono)
                        .frame(width: .spacing10, alignment: .trailing)
                }
            }
            .padding(.spacing3)
            .background(Color.surfaceSecondary.opacity(.opacityLight))
            .cornerRadius(.radiusMedium)

            // Statistics
            CollapsibleSection(
                title: "Statistics",
                icon: "chart.bar.fill",
                isExpanded: true
            ) {
                VStack(alignment: .leading, spacing: .spacing2_5) {
                    HStack {
                        Text("Total Stitches:")
                            .font(.label)
                        Spacer()
                        Text("\(documentState.totalStitchCount)")
                            .font(.mono)
                            .foregroundColor(.textSecondary)
                    }

                    HStack {
                        Text("Colors:")
                            .font(.label)
                        Spacer()
                        Text("\(documentState.document.metadata.colorCount)")
                            .font(.mono)
                            .foregroundColor(.textSecondary)
                    }

                    HStack {
                        Text("Est. Time:")
                            .font(.label)
                        Spacer()
                        Text("-- min")
                            .font(.mono)
                            .foregroundColor(.textSecondary)
                    }
                }
            }

            Spacer()
        }
        .padding(.spacing3)
    }
}
