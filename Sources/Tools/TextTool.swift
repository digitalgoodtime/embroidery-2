//
//  TextTool.swift
//  EmbroideryStudio
//
//  Text and monogram tool (noop implementation)
//

import SwiftUI

struct TextTool: Tool {
    let id = "text"
    let name = "Text"
    let icon = "textformat"
    let tooltip = "Add embroidery text and monograms (T)"
    let category = ToolCategory.text
    let keyboardShortcut: KeyEquivalent? = "t"

    func activate() {
        print("Text tool activated")
    }

    func handleMouseDown(at point: CGPoint) {
        print("Text: Click at \(point)")
        // TODO: Show text input dialog
        // TODO: Font selection
        // TODO: Monogram options
        // TODO: Convert text to stitches
    }
}
