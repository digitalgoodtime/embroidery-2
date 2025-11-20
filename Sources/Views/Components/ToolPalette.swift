//
//  ToolPalette.swift
//  EmbroideryStudio
//
//  Vertical tool palette - Photoshop/Illustrator style
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
                        VStack(spacing: 2) {
                            ForEach(tools, id: \.id) { tool in
                                ToolPaletteButton(
                                    tool: tool,
                                    isSelected: toolManager.selectedTool?.id == tool.id,
                                    action: {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            toolManager.selectTool(tool)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.vertical, 6)

                        // Category divider (except for last category)
                        if category != ToolCategory.allCases.last {
                            Divider()
                                .padding(.horizontal, 12)
                                .opacity(0.5)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .frame(width: 52)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.4))
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
                .font(.system(size: 18, weight: .regular))
                .imageScale(.medium)
                .frame(width: 44, height: 38)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(backgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(borderColor, lineWidth: borderWidth)
                )
                .foregroundColor(foregroundColor)
        }
        .buttonStyle(.borderless)
        .help(tooltipText)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovering = hovering
            }
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.accentColor
        } else if isHovering {
            return Color.secondary.opacity(0.12)
        } else {
            return Color.clear
        }
    }

    private var foregroundColor: Color {
        isSelected ? .white : .primary
    }

    private var borderColor: Color {
        if isSelected {
            return Color.accentColor.opacity(0.3)
        } else {
            return Color.clear
        }
    }

    private var borderWidth: CGFloat {
        isSelected ? 1.5 : 0
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
