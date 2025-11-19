//
//  SelectionTool.swift
//  EmbroideryStudio
//
//  Selection and move tool (noop implementation)
//

import SwiftUI

struct SelectionTool: Tool {
    let id = "selection"
    let name = "Selection"
    let icon = "arrow.up.left.and.arrow.down.right"
    let tooltip = "Select and move objects (V)"
    let category = ToolCategory.selection
    let keyboardShortcut: KeyEquivalent? = "v"

    func activate() {
        print("Selection tool activated")
    }

    func handleMouseDown(at point: CGPoint) {
        print("Selection: Mouse down at \(point)")
        // TODO: Implement selection logic
    }

    func handleMouseDragged(to point: CGPoint) {
        // TODO: Implement drag/move logic
    }

    func handleMouseUp(at point: CGPoint) {
        // TODO: Finalize selection
    }
}
