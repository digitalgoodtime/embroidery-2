//
//  DocumentState.swift
//  EmbroideryStudio
//
//  Manages document state and operations
//

import SwiftUI
import Combine

class DocumentState: ObservableObject {
    @Published var document: EmbroideryDocument
    @Published var selectedLayerID: UUID?
    @Published var zoomLevel: Double = 1.0
    @Published var canvasOffset: CGPoint = .zero
    @Published var isDirty: Bool = false

    // UI State
    @Published var showGrid: Bool = true
    @Published var showHoop: Bool = true
    @Published var showRulers: Bool = true
    @Published var snapToGrid: Bool = false

    // Stitch Player State
    @Published var isPlaying: Bool = false
    @Published var playbackSpeed: Double = 1.0
    @Published var currentStitchIndex: Int = 0

    // Stitch Visualization State
    @Published var showStitchPoints: Bool = false
    @Published var showThreadPath: Bool = false
    @Published var stitchPointSize: Double = 2.0 // radius in pixels

    // Text Tool State
    @Published var showTextDialog: Bool = false
    @Published var textDialogPosition: CGPoint = .zero

    init(document: EmbroideryDocument) {
        self.document = document
    }

    // MARK: - Layer Management

    func addLayer(named name: String) {
        let layer = EmbroideryLayer(name: name)
        document.layers.append(layer)
        selectedLayerID = layer.id
        isDirty = true
    }

    func deleteLayer(id: UUID) {
        document.layers.removeAll { $0.id == id }
        if selectedLayerID == id {
            selectedLayerID = document.layers.first?.id
        }
        isDirty = true
    }

    func duplicateLayer(id: UUID) {
        guard let layer = document.layers.first(where: { $0.id == id }) else { return }
        var newLayer = layer
        newLayer.id = UUID()
        newLayer.name = "\(layer.name) Copy"
        if let index = document.layers.firstIndex(where: { $0.id == id }) {
            document.layers.insert(newLayer, at: index + 1)
        }
        isDirty = true
    }

    func toggleLayerVisibility(id: UUID) {
        if let index = document.layers.firstIndex(where: { $0.id == id }) {
            document.layers[index].isVisible.toggle()
        }
    }

    func toggleLayerLock(id: UUID) {
        if let index = document.layers.firstIndex(where: { $0.id == id }) {
            document.layers[index].isLocked.toggle()
        }
    }

    // MARK: - Canvas Operations

    func zoomIn() {
        zoomLevel = min(zoomLevel * 1.2, 10.0)
    }

    func zoomOut() {
        zoomLevel = max(zoomLevel / 1.2, 0.1)
    }

    func zoomToFit() {
        zoomLevel = 1.0
        canvasOffset = .zero
    }

    func zoom(to level: Double) {
        zoomLevel = max(0.1, min(10.0, level))
    }

    // MARK: - Stitch Player

    func playStitches() {
        isPlaying = true
        // TODO: Implement actual playback
    }

    func pauseStitches() {
        isPlaying = false
    }

    func stopStitches() {
        isPlaying = false
        currentStitchIndex = 0
    }

    func stepForward() {
        currentStitchIndex = min(currentStitchIndex + 1, totalStitchCount - 1)
    }

    func stepBackward() {
        currentStitchIndex = max(currentStitchIndex - 1, 0)
    }

    var totalStitchCount: Int {
        document.layers.reduce(0) { total, layer in
            total + layer.stitches.reduce(0) { $0 + $1.points.count }
        }
    }

    // MARK: - Text Tool

    func showTextInput(at position: CGPoint) {
        textDialogPosition = position
        showTextDialog = true
    }

    func addText(_ textObject: TextObject) {
        // Get current layer or create one
        let targetLayerID: UUID
        if let selectedID = selectedLayerID {
            targetLayerID = selectedID
        } else if let firstLayer = document.layers.first {
            targetLayerID = firstLayer.id
            selectedLayerID = firstLayer.id
        } else {
            // Create a new layer if none exists
            let newLayer = EmbroideryLayer(name: "Layer 1")
            document.layers.append(newLayer)
            targetLayerID = newLayer.id
            selectedLayerID = newLayer.id
        }

        // Generate stitches for the text
        let stitchGenerator = TextStitchGenerator()
        let (stitchGroups, bounds) = stitchGenerator.generateStitches(for: textObject)

        // Add stitches to the layer
        if let layerIndex = document.layers.firstIndex(where: { $0.id == targetLayerID }) {
            document.layers[layerIndex].stitches.append(contentsOf: stitchGroups)
        }

        isDirty = true
    }
}
