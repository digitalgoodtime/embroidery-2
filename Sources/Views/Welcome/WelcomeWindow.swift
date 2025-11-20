//
//  WelcomeWindow.swift
//  EmbroideryStudio
//
//  Welcome screen for new users and quick access with Liquid Glass design
//

import SwiftUI

struct WelcomeWindow: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack(spacing: 0) {
            // Left side - Hero
            VStack(spacing: .spacing6) {
                Spacer()

                Image(systemName: "square.3.layers.3d.down.right")
                    .font(.system(size: .iconHeroXL))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentColor, .accentHigh],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .accentMedium, radius: .spacing5, x: 0, y: .spacing2_5)

                VStack(spacing: .spacing2) {
                    Text("Embroidery Studio")
                        .font(.headingHero)
                        .foregroundColor(.textPrimary)

                    Text("Professional embroidery design for Mac")
                        .font(.headingMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        Color.surfaceSecondary.opacity(.opacityMuted),
                        Color.surfaceSecondary.opacity(.opacityVeryStrong)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Embroidery Studio")
            .accessibilityHint("Professional embroidery design application")

            // Right side - Actions
            VStack(alignment: .leading, spacing: .spacing6) {
                VStack(alignment: .leading, spacing: .spacing3) {
                    Text("Get Started")
                        .font(.headingLarge)

                    Divider()
                }

                // New Document Options
                VStack(alignment: .leading, spacing: .spacing3) {
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
                VStack(alignment: .leading, spacing: .spacing2) {
                    Text("Recent")
                        .font(.bodyEmphasis)
                        .foregroundColor(.textSecondary)

                    Text("No recent documents")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .padding(.vertical, .spacing5)
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
            .padding(.spacing7 + .spacing0_5)
            .frame(width: .sidebarMaxWidth)
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
            HStack(spacing: .spacing3_5) {
                Image(systemName: icon)
                    .font(.system(size: .iconXLarge))
                    .foregroundColor(.accentColor.opacity(isHovering ? 1.0 : .opacityHigh))
                    .frame(width: .controlLarge + .spacing3, height: .controlLarge + .spacing3)
                    .background(
                        Circle()
                            .fill(Color.accentColor.opacity(isHovering ? .opacityMediumLight : .opacityLight))
                    )
                    .shadowSubtle()

                VStack(alignment: .leading, spacing: .spacing0_5 + 1) {
                    Text(title)
                        .font(.bodySemibold)
                        .foregroundColor(.textPrimary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: .iconSmall, weight: .semibold))
                    .foregroundColor(.textSecondary.opacity(.opacityMuted))
                    .opacity(isHovering ? 1 : .opacityDisabled)
            }
            .padding(.horizontal, .spacing3_5)
            .padding(.vertical, .spacing3)
            .background(
                RoundedRectangle(cornerRadius: .radiusMedium)
                    .fill(isHovering ? Color.accentSubtle : Color.surfaceSecondary.opacity(.opacityMedium))
            )
            .overlay(
                RoundedRectangle(cornerRadius: .radiusMedium)
                    .strokeBorder(
                        isHovering ? Color.borderAccent : Color.borderSubtle,
                        lineWidth: .lineStandard
                    )
            )
            .shadowLight()
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.uiDefault) {
                isHovering = hovering
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    WelcomeWindow()
}
