//
//  Protocols.swift
//  EmbroideryStudio
//
//  Core protocols for extensible architecture
//

import SwiftUI

// MARK: - Tool Protocol

protocol Tool: Identifiable {
    var id: String { get }
    var name: String { get }
    var icon: String { get }
    var tooltip: String { get }
    var category: ToolCategory { get }
    var keyboardShortcut: KeyEquivalent? { get }

    /// Called when the tool is selected
    func activate()

    /// Called when the tool is deselected
    func deactivate()

    /// Handle mouse/pointer events on canvas
    func handleMouseDown(at point: CGPoint)
    func handleMouseDragged(to point: CGPoint)
    func handleMouseUp(at point: CGPoint)
}

extension Tool {
    var keyboardShortcut: KeyEquivalent? { nil }

    func activate() {}
    func deactivate() {}
    func handleMouseDown(at point: CGPoint) {}
    func handleMouseDragged(to point: CGPoint) {}
    func handleMouseUp(at point: CGPoint) {}
}

// MARK: - Tool Category

enum ToolCategory: String, CaseIterable {
    case selection = "Selection"
    case digitizing = "Digitizing"
    case editing = "Editing"
    case text = "Text"
    case shapes = "Shapes"
    case transform = "Transform"
    case view = "View"
}

// MARK: - Panel Protocol

protocol SidebarPanel {
    var id: String { get }
    var title: String { get }
    var icon: String { get }
    var defaultWidth: CGFloat { get }
}

// MARK: - Command Protocol

protocol EmbroideryCommand {
    var name: String { get }
    var isEnabled: Bool { get }

    func execute()
    func undo()
}

// MARK: - Export Format Protocol

protocol ExportFormat {
    var name: String { get }
    var fileExtension: String { get }
    var description: String { get }

    func export(document: EmbroideryDocument) throws -> Data
}

// MARK: - Import Format Protocol

protocol ImportFormat {
    var name: String { get }
    var fileExtension: String { get }

    func canImport(data: Data) -> Bool
    func `import`(data: Data) throws -> EmbroideryDocument
}

// MARK: - Stitch Generator Protocol

protocol StitchGenerator {
    var name: String { get }
    var type: StitchType { get }

    func generate(for path: [CGPoint], density: Double, color: CodableColor) -> [StitchPoint]
}
