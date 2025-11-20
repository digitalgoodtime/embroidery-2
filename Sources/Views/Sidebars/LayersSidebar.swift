//
//  LayersSidebar.swift
//  EmbroideryStudio
//
//  Layers management sidebar (left side, Pixelmator Pro style)
//

import SwiftUI

struct LayersSidebar: View {
    @ObservedObject var documentState: DocumentState

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Layers")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Spacer()

                Menu {
                    Button("New Layer") {
                        withAnimation {
                            documentState.addLayer(named: "Layer \(documentState.document.layers.count + 1)")
                        }
                    }
                    Button("Delete Layer") {
                        if let id = documentState.selectedLayerID {
                            withAnimation {
                                documentState.deleteLayer(id: id)
                            }
                        }
                    }
                    .disabled(documentState.selectedLayerID == nil)
                    Button("Duplicate Layer") {
                        if let id = documentState.selectedLayerID {
                            withAnimation {
                                documentState.duplicateLayer(id: id)
                            }
                        }
                    }
                    .disabled(documentState.selectedLayerID == nil)

                    Divider()

                    Button("Merge Down") {
                        // TODO: Implement
                    }
                    .disabled(true)

                    Button("Merge Visible") {
                        // TODO: Implement
                    }
                    .disabled(true)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .menuStyle(.borderlessButton)
                .frame(width: 20, height: 20)
            }
            .padding()

            Divider()

            // Layers List
            if documentState.document.layers.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "square.3.layers.3d")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text("No Layers")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("Create a new layer to start designing")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button("New Layer") {
                        withAnimation {
                            documentState.addLayer(named: "Layer 1")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxHeight: .infinity)
                .padding()
            } else {
                List {
                    ForEach(documentState.document.layers.reversed()) { layer in
                        LayerRow(
                            layer: layer,
                            isSelected: documentState.selectedLayerID == layer.id,
                            documentState: documentState
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                    }
                    .onMove { from, to in
                        var layers = Array(documentState.document.layers.reversed())
                        layers.move(fromOffsets: from, toOffset: to)
                        documentState.document.layers = Array(layers.reversed())
                    }
                }
                .listStyle(.plain)
            }

            Divider()

            // Footer with actions
            HStack(spacing: 8) {
                Button(action: {
                    withAnimation {
                        documentState.addLayer(named: "Layer \(documentState.document.layers.count + 1)")
                    }
                }) {
                    Image(systemName: "plus")
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.borderless)
                .help("New Layer (⌘⇧N)")

                Button(action: {
                    if let id = documentState.selectedLayerID {
                        withAnimation {
                            documentState.deleteLayer(id: id)
                        }
                    }
                }) {
                    Image(systemName: "minus")
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.borderless)
                .disabled(documentState.selectedLayerID == nil)
                .help("Delete Layer (⌫)")

                Spacer()

                Text("\(documentState.document.layers.count) layers")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(8)
        }
    }
}

// MARK: - Layer Row

struct LayerRow: View {
    let layer: EmbroideryLayer
    let isSelected: Bool
    @ObservedObject var documentState: DocumentState

    @State private var isHovering = false
    @State private var showOpacity = false

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                // Visibility toggle
                Button(action: {
                    documentState.toggleLayerVisibility(id: layer.id)
                }) {
                    Image(systemName: layer.isVisible ? "eye.fill" : "eye.slash")
                        .foregroundColor(layer.isVisible ? .primary : .secondary)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.borderless)
                .help(layer.isVisible ? "Hide Layer" : "Show Layer")

                // Thumbnail (placeholder)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.accentColor.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay {
                        Image(systemName: "square.on.square.dashed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                // Layer name
                VStack(alignment: .leading, spacing: 2) {
                    Text(layer.name)
                        .font(.subheadline)
                        .lineLimit(1)

                    Text("\(layer.stitches.count) stitch groups")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Opacity indicator
                if showOpacity || isHovering {
                    Text("\(Int(layer.opacity * 100))%")
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.secondary)
                        .frame(width: 40, alignment: .trailing)
                        .onTapGesture {
                            withAnimation {
                                showOpacity.toggle()
                            }
                        }
                }

                // Lock toggle
                Button(action: {
                    documentState.toggleLayerLock(id: layer.id)
                }) {
                    Image(systemName: layer.isLocked ? "lock.fill" : "lock.open")
                        .foregroundColor(layer.isLocked ? .primary : .secondary)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.borderless)
                .help(layer.isLocked ? "Unlock Layer" : "Lock Layer")
                .opacity(isHovering || layer.isLocked ? 1 : 0)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            .cornerRadius(6)

            // Opacity slider (shown when clicked)
            if showOpacity {
                HStack(spacing: 8) {
                    Text("Opacity:")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Slider(value: opacityBinding, in: 0...1)
                        .controlSize(.small)

                    Text("\(Int(layer.opacity * 100))%")
                        .font(.caption2.monospacedDigit())
                        .foregroundColor(.secondary)
                        .frame(width: 35, alignment: .trailing)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 4)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            documentState.selectedLayerID = layer.id
        }
        .onHover { hovering in
            isHovering = hovering
        }
        .contextMenu {
            Button("Rename") {
                // TODO: Implement rename
            }
            Button("Duplicate") {
                documentState.duplicateLayer(id: layer.id)
            }
            Divider()
            Button("Delete", role: .destructive) {
                documentState.deleteLayer(id: layer.id)
            }
        }
    }

    private var opacityBinding: Binding<Double> {
        Binding(
            get: { layer.opacity },
            set: { newValue in
                if let index = documentState.document.layers.firstIndex(where: { $0.id == layer.id }) {
                    documentState.document.layers[index].opacity = newValue
                }
            }
        )
    }
}
