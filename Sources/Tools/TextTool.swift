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

    private let textState = TextToolState.shared

    func activate() {
        // Tool is now active
    }

    func handleMouseDown(at point: CGPoint) {
        // Create text object from current properties
        let textObject = textState.createTextObject(at: point)

        // Validate
        let issues = textState.validate()
        let hasErrors = issues.contains { $0.severity == .error }

        // Don't place if there are validation errors
        guard !hasErrors else {
            print("Text tool: Cannot place text - validation errors")
            return
        }

        // Post notification to add text to document
        NotificationCenter.default.post(
            name: .addTextToDocument,
            object: nil,
            userInfo: [TextToolNotificationKey.textObject: textObject]
        )
    }
}
