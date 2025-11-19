//
//  ToolManager.swift
//  EmbroideryStudio
//
//  Manages tools and tool selection
//

import SwiftUI
import Combine

class ToolManager: ObservableObject {
    static let shared = ToolManager()

    @Published var selectedTool: (any Tool)?
    @Published var availableTools: [any Tool] = []

    private init() {
        registerDefaultTools()
    }

    func selectTool(_ tool: any Tool) {
        selectedTool?.deactivate()
        selectedTool = tool
        selectedTool?.activate()
    }

    func registerTool(_ tool: any Tool) {
        if !availableTools.contains(where: { $0.id == tool.id }) {
            availableTools.append(tool)
        }
    }

    private func registerDefaultTools() {
        // Register all default tools
        let defaultTools: [any Tool] = [
            SelectionTool(),
            AutoDigitizeTool(),
            ManualDigitizeTool(),
            TextTool(),
            ShapeTool(),
            ZoomTool()
        ]

        defaultTools.forEach { registerTool($0) }
        selectedTool = defaultTools.first
    }

    func tools(for category: ToolCategory) -> [any Tool] {
        availableTools.filter { $0.category == category }
    }
}
