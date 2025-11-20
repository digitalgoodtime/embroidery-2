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
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "square.3.layers.3d.down.right")
                    .font(.system(size: 90))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentColor, .accentColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .accentColor.opacity(0.2), radius: 20, x: 0, y: 10)

                VStack(spacing: 8) {
                    Text("Embroidery Studio")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("Professional embroidery design for Mac")
                        .font(.system(.title3))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        Color(nsColor: .controlBackgroundColor).opacity(0.6),
                        Color(nsColor: .controlBackgroundColor).opacity(0.4)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

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
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.accentColor.opacity(isHovering ? 1.0 : 0.8))
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.accentColor.opacity(isHovering ? 0.15 : 0.1))
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(.body, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(.caption))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.6))
                    .opacity(isHovering ? 1 : 0.5)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovering ? Color.accentColor.opacity(0.08) : Color(nsColor: .controlBackgroundColor).opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        isHovering ? Color.accentColor.opacity(0.3) : Color(nsColor: .separatorColor).opacity(0.5),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

#Preview {
    WelcomeWindow()
}
