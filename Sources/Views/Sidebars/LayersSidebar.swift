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
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundColor(.primary)

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
                        .foregroundColor(.secondary)
                }
                .menuStyle(.borderlessButton)
                .frame(width: 20, height: 20)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()

            // Layers List
            if documentState.document.layers.isEmpty {
                VStack(spacing: 16) {
                    Spacer()

                    VStack(spacing: 12) {
                        Image(systemName: "square.3.layers.3d")
                            .font(.system(size: 56))
                            .foregroundColor(.accentColor.opacity(0.4))
                            .symbolRenderingMode(.hierarchical)

                        VStack(spacing: 6) {
                            Text("No Layers")
                                .font(.system(.title3, weight: .semibold))
                                .foregroundColor(.primary.opacity(0.8))

                            Text("Create a new layer to start designing your embroidery")
                                .font(.system(.callout))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            documentState.addLayer(named: "Layer 1")
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 14))
                            Text("Create Layer")
                                .font(.system(.callout, weight: .medium))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(24)
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
            HStack(spacing: 6) {
                Button(action: {
                    withAnimation {
                        documentState.addLayer(named: "Layer \(documentState.document.layers.count + 1)")
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .frame(width: 24, height: 24)
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
                        .font(.system(size: 14, weight: .medium))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.borderless)
                .disabled(documentState.selectedLayerID == nil)
                .help("Delete Layer (⌫)")

                Spacer()

                Text("\(documentState.document.layers.count) layer\(documentState.document.layers.count == 1 ? "" : "s")")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
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
            HStack(spacing: 10) {
                // Visibility toggle
                Button(action: {
                    documentState.toggleLayerVisibility(id: layer.id)
                }) {
                    Image(systemName: layer.isVisible ? "eye.fill" : "eye.slash")
                        .font(.system(size: 13))
                        .foregroundColor(layer.isVisible ? .primary.opacity(0.7) : .secondary.opacity(0.6))
                        .frame(width: 18, height: 18)
                }
                .buttonStyle(.borderless)
                .help(layer.isVisible ? "Hide Layer" : "Show Layer")

                // Thumbnail (placeholder)
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0.4), Color.accentColor.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 34, height: 34)
                    .overlay {
                        Image(systemName: "square.on.square.dashed")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .strokeBorder(Color.black.opacity(0.1), lineWidth: 0.5)
                    )

                // Layer name
                VStack(alignment: .leading, spacing: 3) {
                    Text(layer.name)
                        .font(.system(.subheadline, weight: .medium))
                        .lineLimit(1)

                    Text("\(layer.stitches.count) stitch group\(layer.stitches.count == 1 ? "" : "s")")
                        .font(.system(.caption2))
                        .foregroundColor(.secondary)
                }

                Spacer(minLength: 4)

                // Opacity indicator
                if showOpacity || isHovering {
                    Text("\(Int(layer.opacity * 100))%")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                        .frame(width: 38, alignment: .trailing)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                showOpacity.toggle()
                            }
                        }
                }

                // Lock toggle
                Button(action: {
                    documentState.toggleLayerLock(id: layer.id)
                }) {
                    Image(systemName: layer.isLocked ? "lock.fill" : "lock.open")
                        .font(.system(size: 13))
                        .foregroundColor(layer.isLocked ? .orange.opacity(0.9) : .secondary.opacity(0.6))
                        .frame(width: 18, height: 18)
                }
                .buttonStyle(.borderless)
                .help(layer.isLocked ? "Unlock Layer" : "Lock Layer")
                .opacity(isHovering || layer.isLocked ? 1 : 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isSelected ? Color.accentColor.opacity(0.18) : (isHovering ? Color.secondary.opacity(0.06) : Color.clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(isSelected ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
            )

            // Opacity slider (shown when clicked)
            if showOpacity {
                HStack(spacing: 10) {
                    Text("Opacity:")
                        .font(.system(.caption2, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 52, alignment: .leading)

                    Slider(value: opacityBinding, in: 0...1)
                        .controlSize(.small)
                        .tint(.accentColor)

                    Text("\(Int(layer.opacity * 100))%")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.primary.opacity(0.8))
                        .frame(width: 36, alignment: .trailing)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.2))
                .cornerRadius(4)
                .padding(.horizontal, 6)
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
