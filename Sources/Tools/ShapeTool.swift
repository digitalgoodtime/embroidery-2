//
//  ShapeTool.swift
//  EmbroideryStudio
//
//  Shape drawing tool (noop implementation)
//

import SwiftUI

struct ShapeTool: Tool {
    let id = "shape"
    let name = "Shape"
    let icon = "circle.square"
    let tooltip = "Draw basic shapes (S)"
    let category = ToolCategory.shapes
    let keyboardShortcut: KeyEquivalent? = "s"

    func activate() {
        print("Shape tool activated")
    }

    func handleMouseDown(at point: CGPoint) {
        print("Shape: Start at \(point)")
        // TODO: Begin shape drawing
    }

    func handleMouseDragged(to point: CGPoint) {
        // TODO: Update shape preview
    }

    func handleMouseUp(at point: CGPoint) {
        print("Shape: Complete")
        // TODO: Generate stitches for shape
    }
}
