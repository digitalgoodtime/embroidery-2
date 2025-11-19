//
//  ZoomTool.swift
//  EmbroideryStudio
//
//  Zoom and pan tool (noop implementation)
//

import SwiftUI

struct ZoomTool: Tool {
    let id = "zoom"
    let name = "Zoom"
    let icon = "magnifyingglass"
    let tooltip = "Zoom and pan canvas (Z)"
    let category = ToolCategory.view
    let keyboardShortcut: KeyEquivalent? = "z"

    func activate() {
        print("Zoom tool activated")
    }

    func handleMouseDown(at point: CGPoint) {
        print("Zoom: Click at \(point)")
        // TODO: Zoom in on click
        // TODO: Option+click to zoom out
    }

    func handleMouseDragged(to point: CGPoint) {
        // TODO: Pan canvas while dragging
    }
}
