//
//  TextTool.swift
//  EmbroideryStudio
//
//  Text and monogram tool for adding embroidery text
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
        // Tool is now active
    }

    func handleMouseDown(at point: CGPoint) {
        // Post notification to show text input dialog
        NotificationCenter.default.post(
            name: .showTextInputDialog,
            object: nil,
            userInfo: [TextToolNotificationKey.position: NSValue(point: point)]
        )
    }
}
