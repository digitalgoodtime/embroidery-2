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
            TextToolProperties(documentState: documentState)
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
    @ObservedObject var documentState: DocumentState
    @ObservedObject var textState = TextToolState.shared

    @State private var validationIssues: [TextStitchGenerator.ValidationIssue] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacing2_5) {
                // Instructions
                HStack(alignment: .top, spacing: .spacing2) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: .iconSmall))
                        .foregroundColor(.accentColor)

                    Text("Enter text below, then click canvas to place")
                        .font(.captionSmall)
                        .foregroundColor(.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.spacing2)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(.radiusSmall)

                // Text Input
                VStack(alignment: .leading, spacing: .spacing1_5) {
                    Text("Text")
                        .font(.label)
                        .foregroundColor(.textPrimary)

                    TextField("Enter text...", text: $textState.text, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...3)
                        .font(.system(size: 12))
                }

                Divider()

                // Font Selection
                VStack(alignment: .leading, spacing: .spacing1_5) {
                    Text("Font")
                        .font(.label)
                        .foregroundColor(.textPrimary)

                    // Search field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 10))

                        TextField("Search...", text: $textState.searchQuery)
                            .textFieldStyle(.plain)
                            .font(.system(size: 11))

                        if !textState.searchQuery.isEmpty {
                            Button(action: { textState.searchQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 10))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.spacing1)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(.radiusSmall)

                    // Font list (compact)
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: .spacing0_5) {
                            ForEach(textState.filteredFonts().prefix(20)) { font in
                                fontRow(font)
                            }
                        }
                    }
                    .frame(height: 120)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(.radiusSmall)

                    // Size slider
                    VStack(alignment: .leading, spacing: .spacing1) {
                        HStack {
                            Text("Size:")
                                .font(.captionSmall)
                            Spacer()
                            Text("\(String(format: "%.1f", textState.fontSize)) mm")
                                .font(.mono)
                                .foregroundColor(.textSecondary)
                        }

                        Slider(value: $textState.fontSize, in: 8.0...100.0, step: 0.5)
                            .controlSize(.small)
                    }
                }

                Divider()

                // Stitch Technique
                VStack(alignment: .leading, spacing: .spacing1_5) {
                    Text("Stitch Technique")
                        .font(.label)
                        .foregroundColor(.textPrimary)

                    Picker("", selection: $textState.stitchTechnique) {
                        ForEach(TextStitchTechnique.allCases, id: \.self) { technique in
                            Label(technique.rawValue, systemImage: technique.icon).tag(technique)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }

                // Colors
                if textState.stitchTechnique.needsOutline {
                    HStack {
                        Text("Outline:")
                            .font(.label)
                        ColorPicker("", selection: Binding(
                            get: { Color(textState.outlineColor.nsColor) },
                            set: { textState.outlineColor = CodableColor(NSColor($0)) }
                        ))
                        .labelsHidden()
                    }
                }

                if textState.stitchTechnique.needsFill {
                    HStack {
                        Text("Fill:")
                            .font(.label)
                        ColorPicker("", selection: Binding(
                            get: { Color(textState.fillColor.nsColor) },
                            set: { textState.fillColor = CodableColor(NSColor($0)) }
                        ))
                        .labelsHidden()
                    }
                }

                Divider()

                // Density
                VStack(alignment: .leading, spacing: .spacing1_5) {
                    HStack {
                        Text("Density:")
                            .font(.label)
                        Spacer()
                        Toggle("Auto", isOn: Binding(
                            get: { textState.densityMode == .auto },
                            set: { textState.densityMode = $0 ? .auto : .manual }
                        ))
                        .toggleStyle(.switch)
                        .controlSize(.mini)
                    }

                    if textState.densityMode == .manual {
                        HStack {
                            Slider(value: $textState.manualDensity, in: 2.0...8.0, step: 0.5)
                                .controlSize(.small)
                            Text("\(String(format: "%.1f", textState.manualDensity)) st/mm")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.textSecondary)
                                .frame(width: 60, alignment: .trailing)
                        }
                    } else {
                        let autoDensity = textState.calculateAutoDensity()
                        Text("Auto: \(String(format: "%.1f", autoDensity)) st/mm")
                            .font(.system(size: 10))
                            .foregroundColor(.textSecondary)
                    }
                }

                // Letter Spacing
                VStack(alignment: .leading, spacing: .spacing1) {
                    HStack {
                        Text("Letter Spacing:")
                            .font(.label)
                        Spacer()
                        Text("\(String(format: "%.1f", textState.letterSpacing)) mm")
                            .font(.mono)
                            .foregroundColor(.textSecondary)
                    }

                    Slider(value: $textState.letterSpacing, in: -2.0...5.0, step: 0.1)
                        .controlSize(.small)
                }

                // Alignment
                VStack(alignment: .leading, spacing: .spacing1_5) {
                    Text("Alignment")
                        .font(.label)
                        .foregroundColor(.textPrimary)

                    Picker("", selection: $textState.alignment) {
                        Label("Left", systemImage: "text.alignleft").tag(TextObject.TextAlignment.left)
                        Label("Center", systemImage: "text.aligncenter").tag(TextObject.TextAlignment.center)
                        Label("Right", systemImage: "text.alignright").tag(TextObject.TextAlignment.right)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }

                Divider()

                // Stitch Visualization
                VStack(alignment: .leading, spacing: .spacing1_5) {
                    Text("Stitch Visualization")
                        .font(.label)
                        .foregroundColor(.textPrimary)

                    Toggle("Show Stitch Points", isOn: $documentState.showStitchPoints)
                        .font(.captionSmall)

                    Toggle("Show Thread Path", isOn: $documentState.showThreadPath)
                        .font(.captionSmall)

                    if documentState.showStitchPoints {
                        HStack {
                            Text("Point Size:")
                                .font(.captionSmall)
                            Spacer()
                            Slider(value: $documentState.stitchPointSize, in: 1.0...5.0, step: 0.5)
                                .controlSize(.mini)
                            Text(String(format: "%.1f", documentState.stitchPointSize))
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.textSecondary)
                                .frame(width: 30)
                        }
                    }
                }

                // Validation warnings
                if !validationIssues.isEmpty {
                    Divider()

                    VStack(alignment: .leading, spacing: .spacing1) {
                        ForEach(validationIssues.indices, id: \.self) { index in
                            let issue = validationIssues[index]
                            HStack(alignment: .top, spacing: .spacing1) {
                                Image(systemName: issue.severity == .error ? "exclamationmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .foregroundStyle(issue.severity == .error ? .red : .yellow)
                                    .font(.system(size: 10))

                                Text(issue.message)
                                    .font(.system(size: 10))
                                    .foregroundColor(.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.spacing1_5)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(.radiusSmall)
                }
            }
        }
        .onChange(of: textState.text) { _ in
            validateText()
            updateSelectedText()
        }
        .onChange(of: textState.fontSize) { _ in
            validateText()
            updateSelectedText()
        }
        .onChange(of: textState.selectedFont) { _ in updateSelectedText() }
        .onChange(of: textState.stitchTechnique) { _ in updateSelectedText() }
        .onChange(of: textState.densityMode) { _ in
            validateText()
            updateSelectedText()
        }
        .onChange(of: textState.manualDensity) { _ in
            validateText()
            updateSelectedText()
        }
        .onChange(of: textState.letterSpacing) { _ in updateSelectedText() }
        .onChange(of: textState.alignment) { _ in updateSelectedText() }
        .onChange(of: textState.outlineColor) { _ in updateSelectedText() }
        .onChange(of: textState.fillColor) { _ in updateSelectedText() }
        .onReceive(NotificationCenter.default.publisher(for: .textSelectionChanged)) { notification in
            if let textObject = notification.userInfo?[TextToolNotificationKey.textObject] as? TextObject {
                textState.loadFrom(textObject)
                validateText()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .createNewText)) { notification in
            if let point = notification.userInfo?[TextToolNotificationKey.point] as? CGPoint {
                let textObject = textState.createTextObject(at: point)
                documentState.addText(textObject)
            }
        }
        .onAppear {
            validateText()
        }
    }

    /// Update the selected text object when properties change
    private func updateSelectedText() {
        if let selectedText = documentState.selectedText {
            let updatedText = textState.updateTextObject(selectedText)
            documentState.updateText(updatedText)
        }
    }

    private func fontRow(_ font: EmbroideryFont) -> some View {
        Button(action: { textState.selectedFont = font }) {
            HStack(spacing: .spacing1_5) {
                Text(font.familyName)
                    .font(.custom(font.id, size: 11))
                    .lineLimit(1)

                Spacer()

                Image(systemName: font.difficulty.icon)
                    .font(.system(size: 8))
                    .foregroundColor(Color(font.difficulty.color))

                if font.id == textState.selectedFont.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.system(size: 10))
                }
            }
            .padding(.horizontal, .spacing1)
            .padding(.vertical, .spacing0_5)
            .background(
                RoundedRectangle(cornerRadius: .radiusXSmall)
                    .fill(font.id == textState.selectedFont.id ? Color.accentColor.opacity(0.15) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    private func validateText() {
        validationIssues = textState.validate()
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
