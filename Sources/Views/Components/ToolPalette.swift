//
//  ToolPalette.swift
//  EmbroideryStudio
//
//  Vertical tool palette - Photoshop/Illustrator style with Liquid Glass design
//

import SwiftUI

struct ToolPalette: View {
    @StateObject private var toolManager = ToolManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Group tools by category
                ForEach(ToolCategory.allCases, id: \.self) { category in
                    let tools = toolManager.tools(for: category)

                    if !tools.isEmpty {
                        // Category tools
                        VStack(spacing: .spacing0_5) {
                            ForEach(tools, id: \.id) { tool in
                                ToolPaletteButton(
                                    tool: tool,
                                    isSelected: toolManager.selectedTool?.id == tool.id,
                                    action: {
                                        withAnimation(.uiDefault) {
                                            toolManager.selectTool(tool)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.vertical, .spacing1_5)

                        // Category divider (except for last category)
                        if category != ToolCategory.allCases.last {
                            Divider()
                                .padding(.horizontal, .spacing3)
                                .opacity(.opacityDisabled)
                        }
                    }
                }
            }
            .padding(.vertical, .spacing2)
        }
        .frame(width: .toolPaletteWidth)
        .background(.ultraThinMaterial)
        .shadowLight()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tool palette")
    }
}

// MARK: - Tool Palette Button

struct ToolPaletteButton: View {
    let tool: any Tool
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: tool.icon)
                .font(.toolIcon(size: .iconMediumLarge))
                .imageScale(.medium)
                .frame(width: .controlLarge + .spacing3, height: .controlXLarge)
                .background(
                    RoundedRectangle(cornerRadius: .radiusSmall)
                        .fill(backgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: .radiusSmall)
                        .strokeBorder(borderColor, lineWidth: borderWidth)
                )
                .foregroundColor(foregroundColor)
        }
        .buttonStyle(.borderless)
        .help(tooltipText)
        .onHover { hovering in
            withAnimation(.uiFast) {
                isHovering = hovering
            }
        }
        .accessibilityLabel(tool.name)
        .accessibilityHint("Activate \(tool.name) tool")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.accentColor
        } else if isHovering {
            return Color.interactiveHoverStrong
        } else {
            return Color.clear
        }
    }

    private var foregroundColor: Color {
        isSelected ? .textOnAccent : .textPrimary
    }

    private var borderColor: Color {
        if isSelected {
            return Color.borderAccent
        } else {
            return Color.clear
        }
    }

    private var borderWidth: CGFloat {
        isSelected ? .lineEmphasis : 0
    }

    private var tooltipText: String {
        if let shortcut = tool.keyboardShortcut {
            return "\(tool.name) (\(shortcut.character.uppercased()))"
        } else {
            return tool.name
        }
    }
}

#Preview {
    ToolPalette()
        .frame(height: 600)
}
