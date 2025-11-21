import SwiftUI
import AppKit

/// Dialog for inputting text and configuring embroidery text properties
struct TextInputDialog: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var fontManager = EmbroideryFontManager.shared

    // Text input
    @State private var text: String = ""
    @State private var searchQuery: String = ""

    // Font settings
    @State private var selectedFont: EmbroideryFont
    @State private var fontSize: Double = 20.0 // mm

    // Embroidery settings
    @State private var stitchTechnique: TextStitchTechnique = .fillWithOutline
    @State private var densityMode: TextObject.DensityMode = .auto
    @State private var manualDensity: Double = 4.0
    @State private var outlineColor: CodableColor
    @State private var fillColor: CodableColor
    @State private var letterSpacing: Double = 0.0
    @State private var alignment: TextObject.TextAlignment = .left

    // Validation
    @State private var validationIssues: [TextStitchGenerator.ValidationIssue] = []

    let position: CGPoint
    let onConfirm: (TextObject) -> Void

    private let stitchGenerator = TextStitchGenerator()

    init(position: CGPoint, defaultColor: CodableColor, onConfirm: @escaping (TextObject) -> Void) {
        self.position = position
        self.onConfirm = onConfirm

        // Initialize with default font
        let defaultFont = EmbroideryFontManager.shared.defaultFont()
        _selectedFont = State(initialValue: defaultFont)

        // Initialize colors
        _outlineColor = State(initialValue: defaultColor)
        _fillColor = State(initialValue: defaultColor)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Text")
                    .font(.system(size: 17, weight: .semibold))

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.spacing4)

            Divider()

            // Content
            ScrollView {
                VStack(spacing: .spacing4) {
                    // Text Input
                    textInputSection

                    Divider()

                    // Font Selection
                    fontSelectionSection

                    Divider()

                    // Embroidery Settings
                    embroiderySettingsSection

                    Divider()

                    // Preview (future enhancement)
                    previewSection
                }
                .padding(.spacing4)
            }

            // Validation Issues
            if !validationIssues.isEmpty {
                Divider()
                validationSection
            }

            Divider()

            // Footer with actions
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Add Text") {
                    confirmText()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!canConfirm)
            }
            .padding(.spacing4)
        }
        .frame(width: 500, height: 650)
        .onChange(of: text) { _ in validateText() }
        .onChange(of: fontSize) { _ in validateText() }
        .onChange(of: densityMode) { _ in validateText() }
        .onChange(of: manualDensity) { _ in validateText() }
        .onAppear {
            validateText()
        }
    }

    // MARK: - Sections

    private var textInputSection: some View {
        VStack(alignment: .leading, spacing: .spacing3) {
            Text("Text")
                .font(.system(size: 13, weight: .semibold))

            TextField("Enter text...", text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...5)
                .font(.system(size: 14))
        }
    }

    private var fontSelectionSection: some View {
        VStack(alignment: .leading, spacing: .spacing3) {
            Text("Font")
                .font(.system(size: 13, weight: .semibold))

            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 12))

                TextField("Search fonts...", text: $searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))

                if !searchQuery.isEmpty {
                    Button(action: { searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.spacing2)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(.radiusSmall)

            // Font list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: .spacing2) {
                    ForEach(filteredFonts) { font in
                        fontRow(font)
                    }
                }
            }
            .frame(height: 150)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(.radiusMedium)

            // Size slider
            VStack(alignment: .leading, spacing: .spacing2) {
                HStack {
                    Text("Size")
                        .font(.system(size: 12))
                    Spacer()
                    Text("\(String(format: "%.1f", fontSize)) mm")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.secondary)
                }

                Slider(value: $fontSize, in: 8.0...100.0, step: 0.5)
            }
        }
    }

    private var embroiderySettingsSection: some View {
        VStack(alignment: .leading, spacing: .spacing3) {
            Text("Embroidery Settings")
                .font(.system(size: 13, weight: .semibold))

            // Stitch Technique
            VStack(alignment: .leading, spacing: .spacing2) {
                Text("Stitch Technique")
                    .font(.system(size: 12))

                Picker("", selection: $stitchTechnique) {
                    ForEach(TextStitchTechnique.allCases, id: \.self) { technique in
                        HStack {
                            Image(systemName: technique.icon)
                            Text(technique.rawValue)
                        }
                        .tag(technique)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Colors
            HStack(spacing: .spacing3) {
                if stitchTechnique.needsOutline {
                    VStack(alignment: .leading, spacing: .spacing2) {
                        Text("Outline Color")
                            .font(.system(size: 12))

                        ColorPicker("", selection: Binding(
                            get: { Color(outlineColor.nsColor) },
                            set: { outlineColor = CodableColor(NSColor($0)) }
                        ))
                        .labelsHidden()
                    }
                }

                if stitchTechnique.needsFill {
                    VStack(alignment: .leading, spacing: .spacing2) {
                        Text("Fill Color")
                            .font(.system(size: 12))

                        ColorPicker("", selection: Binding(
                            get: { Color(fillColor.nsColor) },
                            set: { fillColor = CodableColor(NSColor($0)) }
                        ))
                        .labelsHidden()
                    }
                }
            }

            // Density Mode
            VStack(alignment: .leading, spacing: .spacing2) {
                HStack {
                    Text("Stitch Density")
                        .font(.system(size: 12))

                    Spacer()

                    Toggle("Auto", isOn: Binding(
                        get: { densityMode == .auto },
                        set: { densityMode = $0 ? .auto : .manual }
                    ))
                    .toggleStyle(.switch)
                    .controlSize(.mini)
                }

                if densityMode == .manual {
                    HStack {
                        Slider(value: $manualDensity, in: 2.0...8.0, step: 0.5)
                        Text("\(String(format: "%.1f", manualDensity)) st/mm")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(width: 70, alignment: .trailing)
                    }
                } else {
                    let autoDensity = calculateAutoDensity()
                    Text("Auto: \(String(format: "%.1f", autoDensity)) stitches/mm")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }

            // Letter Spacing
            VStack(alignment: .leading, spacing: .spacing2) {
                HStack {
                    Text("Letter Spacing")
                        .font(.system(size: 12))
                    Spacer()
                    Text("\(String(format: "%.1f", letterSpacing)) mm")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                }

                Slider(value: $letterSpacing, in: -2.0...5.0, step: 0.1)
            }

            // Alignment
            VStack(alignment: .leading, spacing: .spacing2) {
                Text("Alignment")
                    .font(.system(size: 12))

                Picker("", selection: $alignment) {
                    Label("Left", systemImage: "text.alignleft").tag(TextObject.TextAlignment.left)
                    Label("Center", systemImage: "text.aligncenter").tag(TextObject.TextAlignment.center)
                    Label("Right", systemImage: "text.alignright").tag(TextObject.TextAlignment.right)
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: .spacing2) {
            Text("Preview")
                .font(.system(size: 13, weight: .semibold))

            // Placeholder for preview
            ZStack {
                RoundedRectangle(cornerRadius: .radiusMedium)
                    .fill(Color(nsColor: .controlBackgroundColor))

                if text.isEmpty {
                    Text("Enter text to see preview")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                } else {
                    Text(text)
                        .font(.custom(selectedFont.id, size: 24))
                        .foregroundColor(Color(outlineColor.nsColor))
                }
            }
            .frame(height: 80)
        }
    }

    private var validationSection: some View {
        VStack(alignment: .leading, spacing: .spacing2) {
            ForEach(validationIssues.indices, id: \.self) { index in
                let issue = validationIssues[index]
                HStack(alignment: .top, spacing: .spacing2) {
                    Image(systemName: issue.severity == .error ? "exclamationmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundStyle(issue.severity == .error ? .red : .yellow)
                        .font(.system(size: 12))

                    Text(issue.message)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.spacing3)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
    }

    // MARK: - Font Row

    private func fontRow(_ font: EmbroideryFont) -> some View {
        Button(action: { selectedFont = font }) {
            HStack(spacing: .spacing3) {
                // Font preview
                Text(font.familyName)
                    .font(.custom(font.id, size: 14))
                    .lineLimit(1)

                Spacer()

                // Difficulty indicator
                HStack(spacing: .spacing1) {
                    Image(systemName: font.difficulty.icon)
                        .font(.system(size: 10))
                        .foregroundColor(Color(font.difficulty.color))

                    Text(font.difficulty.rawValue)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }

                // Selection indicator
                if font.id == selectedFont.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.system(size: 14))
                }
            }
            .padding(.horizontal, .spacing2)
            .padding(.vertical, .spacing1)
            .background(
                RoundedRectangle(cornerRadius: .radiusSmall)
                    .fill(font.id == selectedFont.id ? Color.accentColor.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Computed Properties

    private var filteredFonts: [EmbroideryFont] {
        if searchQuery.isEmpty {
            return fontManager.allFonts
        }
        return fontManager.searchFonts(query: searchQuery)
    }

    private var canConfirm: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !validationIssues.contains { $0.severity == .error }
    }

    // MARK: - Actions

    private func calculateAutoDensity() -> Double {
        let minDensity = 3.0
        let maxDensity = 5.0
        let minSize = 8.0
        let maxSize = 50.0

        let normalized = (fontSize - minSize) / (maxSize - minSize)
        let clamped = max(0, min(1, normalized))

        return maxDensity - (clamped * (maxDensity - minDensity))
    }

    private func validateText() {
        let textObject = createTextObject()
        validationIssues = stitchGenerator.validate(textObject)
    }

    private func createTextObject() -> TextObject {
        TextObject(
            text: text,
            position: position,
            fontSize: fontSize,
            fontName: selectedFont.id,
            letterSpacing: letterSpacing,
            alignment: alignment,
            stitchTechnique: stitchTechnique,
            densityMode: densityMode,
            manualDensity: manualDensity,
            outlineColor: outlineColor,
            fillColor: stitchTechnique.needsFill ? fillColor : nil
        )
    }

    private func confirmText() {
        let textObject = createTextObject()
        onConfirm(textObject)
        dismiss()
    }
}
