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
                        VStack(spacing: 4) {
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
                        .padding(.vertical, 8)

                        // Category divider (except for last category)
                        if category != ToolCategory.allCases.last {
                            Divider()
                                .padding(.horizontal, 8)
                        }
                    }
                }
            }
            .padding(.vertical, 12)
        }
        .frame(width: 48)
        .background(.ultraThinMaterial)
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
                .font(.system(size: 20))
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(backgroundColor)
                )
                .foregroundColor(foregroundColor)
        }
        .buttonStyle(.borderless)
        .help(tooltipText)
        .onHover { hovering in
            isHovering = hovering
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.accentColor.opacity(0.8)
        } else if isHovering {
            return Color.secondary.opacity(0.15)
        } else {
            return Color.clear
        }
    }

    private var foregroundColor: Color {
        isSelected ? .white : .primary
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
