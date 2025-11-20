//
//  KeyboardShortcutsOverlay.swift
//  EmbroideryStudio
//
//  Keyboard shortcuts reference overlay
//

import SwiftUI

struct KeyboardShortcutsOverlay: View {
    @Environment(\.dismiss) private var dismiss

    struct ShortcutGroup {
        let title: String
        let shortcuts: [(key: String, description: String)]
    }

    let shortcutGroups: [ShortcutGroup] = [
        ShortcutGroup(title: "Tools", shortcuts: [
            ("V", "Selection Tool"),
            ("A", "Auto Digitize"),
            ("D", "Manual Digitize"),
            ("T", "Text Tool"),
            ("S", "Shape Tool"),
            ("Z", "Zoom Tool")
        ]),
        ShortcutGroup(title: "View", shortcuts: [
            ("⌘ +", "Zoom In"),
            ("⌘ -", "Zoom Out"),
            ("⌘ 0", "Zoom to Fit"),
            ("⌘ '", "Toggle Grid"),
            ("⌘ H", "Toggle Hoop"),
            ("⌘ R", "Toggle Rulers")
        ]),
        ShortcutGroup(title: "Layers", shortcuts: [
            ("⌘ ⇧ N", "New Layer"),
            ("⌘ J", "Duplicate Layer"),
            ("⌘ E", "Merge Down"),
            ("⌫", "Delete Layer")
        ]),
        ShortcutGroup(title: "Panels", shortcuts: [
            ("⌘ ⌥ 1", "Toggle Layers Panel"),
            ("⌘ ⌥ 2", "Toggle Properties Panel")
        ]),
        ShortcutGroup(title: "File", shortcuts: [
            ("⌘ N", "New Document"),
            ("⌘ O", "Open"),
            ("⌘ S", "Save"),
            ("⌘ ⇧ S", "Save As"),
            ("⌘ I", "Import Design"),
            ("⌘ ⇧ I", "Import Image")
        ]),
        ShortcutGroup(title: "Edit", shortcuts: [
            ("⌘ Z", "Undo"),
            ("⌘ ⇧ Z", "Redo"),
            ("⌘ X", "Cut"),
            ("⌘ C", "Copy"),
            ("⌘ V", "Paste"),
            ("⌘ A", "Select All"),
            ("⌘ D", "Deselect All")
        ])
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Keyboard Shortcuts")
                    .font(.title2.bold())

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Close (ESC)")
            }
            .padding()
            .background(.ultraThinMaterial)

            Divider()

            // Shortcuts Grid
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 20),
                        GridItem(.flexible(), spacing: 20)
                    ],
                    alignment: .leading,
                    spacing: 24
                ) {
                    ForEach(shortcutGroups, id: \.title) { group in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(group.title)
                                .font(.headline)
                                .foregroundColor(.secondary)

                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(group.shortcuts, id: \.key) { shortcut in
                                    HStack {
                                        Text(shortcut.key)
                                            .font(.system(.body, design: .monospaced))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.secondary.opacity(0.2))
                                            .cornerRadius(4)
                                            .frame(minWidth: 60, alignment: .leading)

                                        Text(shortcut.description)
                                            .font(.body)

                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }

            Divider()

            // Footer
            HStack {
                Text("Press ⌘ / to toggle this overlay")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .frame(width: 700, height: 600)
    }
}

#Preview {
    KeyboardShortcutsOverlay()
}
