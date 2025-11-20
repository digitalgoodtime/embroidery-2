//
//  WelcomeWindow.swift
//  EmbroideryStudio
//
//  Welcome screen for new users and quick access
//

import SwiftUI

struct WelcomeWindow: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack(spacing: 0) {
            // Left side - Hero
            VStack(spacing: 20) {
                Image(systemName: "square.3.layers.3d.down.right")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentColor, .accentColor.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Embroidery Studio")
                    .font(.system(size: 32, weight: .bold, design: .rounded))

                Text("Professional embroidery design for Mac")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))

            // Right side - Actions
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Get Started")
                        .font(.title2.bold())

                    Divider()
                }

                // New Document Options
                VStack(alignment: .leading, spacing: 12) {
                    WelcomeButton(
                        icon: "doc.badge.plus",
                        title: "New Design",
                        subtitle: "Start with a blank canvas",
                        action: {
                            // TODO: Create new document
                            dismiss()
                        }
                    )

                    Menu {
                        Button("4x4 Hoop") { createDocument(hoop: .standard4x4) }
                        Button("5x7 Hoop") { createDocument(hoop: .large5x7) }
                        Button("6x10 Hoop") { createDocument(hoop: .extraLarge6x10) }
                        Button("8x12 Hoop") { createDocument(hoop: .jumbo8x12) }
                    } label: {
                        WelcomeButton(
                            icon: "circle.dashed",
                            title: "New from Template",
                            subtitle: "Choose a hoop size",
                            action: {}
                        )
                    }
                    .menuStyle(.borderlessButton)

                    WelcomeButton(
                        icon: "folder.badge.plus",
                        title: "Open Design",
                        subtitle: "Open an existing file",
                        action: {
                            // TODO: Open file picker
                            dismiss()
                        }
                    )
                }

                Divider()

                // Recent Documents
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("No recent documents")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 20)
                }

                Spacer()

                // Bottom actions
                HStack {
                    Toggle("Show on startup", isOn: .constant(true))
                        .font(.caption)

                    Spacer()

                    Button("Close") {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
            .padding(30)
            .frame(width: 400)
        }
        .frame(width: 750, height: 500)
    }

    private func createDocument(hoop: EmbroideryCanvas.HoopSize) {
        // TODO: Create document with specific hoop size
        dismiss()
    }
}

// MARK: - Welcome Button

struct WelcomeButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .opacity(isHovering ? 1 : 0)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovering ? Color.accentColor.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

#Preview {
    WelcomeWindow()
}
