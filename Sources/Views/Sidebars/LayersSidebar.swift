//
//  LayersSidebar.swift
//  EmbroideryStudio
//
//  Layers management sidebar (left side, Pixelmator Pro style with Liquid Glass)
//

import SwiftUI

struct LayersSidebar: View {
    @ObservedObject var documentState: DocumentState

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Layers")
                    .font(.headingSmall)
                    .foregroundColor(.textPrimary)

                Spacer()

                Menu {
                    Button("New Layer") {
                        withAnimation(.springQuick) {
                            documentState.addLayer(named: "Layer \(documentState.document.layers.count + 1)")
                        }
                    }
                    Button("Delete Layer") {
                        if let id = documentState.selectedLayerID {
                            withAnimation(.springQuick) {
                                documentState.deleteLayer(id: id)
                            }
                        }
                    }
                    .disabled(documentState.selectedLayerID == nil)
                    Button("Duplicate Layer") {
                        if let id = documentState.selectedLayerID {
                            withAnimation(.springQuick) {
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
                        .foregroundColor(.textSecondary)
                }
                .menuStyle(.borderlessButton)
                .frame(width: .spacing5, height: .spacing5)
                .accessibilityLabel("Layer options menu")
            }
            .padding(.horizontal, .spacing3)
            .padding(.vertical, .spacing2_5)
            .background(Color.surfaceSecondary.opacity(.opacityLight))

            // Layers List
            if documentState.document.layers.isEmpty {
                VStack(spacing: .spacing4) {
                    Spacer()

                    VStack(spacing: .spacing3) {
                        Image(systemName: "square.3.layers.3d")
                            .font(.system(size: .iconHero))
                            .foregroundColor(.accentMedium)
                            .symbolRenderingMode(.hierarchical)

                        VStack(spacing: .spacing1_5) {
                            Text("No Layers")
                                .font(.headingMedium)
                                .foregroundColor(.textPrimary.opacity(.opacityHigh))

                            Text("Create a new layer to start designing your embroidery")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Button {
                        withAnimation(.springQuick) {
                            documentState.addLayer(named: "Layer 1")
                        }
                    } label: {
                        HStack(spacing: .spacing1_5) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: .iconMediumSmall))
                            Text("Create Layer")
                                .font(.label)
                        }
                        .padding(.horizontal, .spacing4)
                        .padding(.vertical, .spacing2)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .accessibilityLabel("Create first layer")
                    .accessibilityHint("Creates a new embroidery layer")

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.spacing6)
            } else {
                List {
                    ForEach(documentState.document.layers.reversed()) { layer in
                        LayerRow(
                            layer: layer,
                            isSelected: documentState.selectedLayerID == layer.id,
                            documentState: documentState
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: .spacing0_5, leading: .spacing2, bottom: .spacing0_5, trailing: .spacing2))
                    }
                    .onMove { from, to in
                        var layers = Array(documentState.document.layers.reversed())
                        layers.move(fromOffsets: from, toOffset: to)
                        documentState.document.layers = Array(layers.reversed())
                    }
                }
                .listStyle(.plain)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Layers list")
            }

            // Footer with actions
            HStack(spacing: .spacing1_5) {
                Button(action: {
                    withAnimation(.springQuick) {
                        documentState.addLayer(named: "Layer \(documentState.document.layers.count + 1)")
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: .iconMediumSmall, weight: .medium))
                        .frame(width: .spacing6, height: .spacing6)
                }
                .buttonStyle(.borderless)
                .help("New Layer (⌘⇧N)")
                .accessibilityLabel("New layer")

                Button(action: {
                    if let id = documentState.selectedLayerID {
                        withAnimation(.springQuick) {
                            documentState.deleteLayer(id: id)
                        }
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: .iconMediumSmall, weight: .medium))
                        .frame(width: .spacing6, height: .spacing6)
                }
                .buttonStyle(.borderless)
                .disabled(documentState.selectedLayerID == nil)
                .opacity(documentState.selectedLayerID == nil ? .opacityDisabled : 1)
                .help("Delete Layer (⌫)")
                .accessibilityLabel("Delete layer")

                Spacer()

                Text("\(documentState.document.layers.count) layer\(documentState.document.layers.count == 1 ? "" : "s")")
                    .font(.rounded)
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, .spacing2_5)
            .padding(.vertical, .spacing1_5)
            .background(Color.surfaceSecondary.opacity(.opacityMedium))
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
        VStack(spacing: .spacing1) {
            HStack(spacing: .spacing2_5) {
                // Drag handle indicator
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: .iconSmall))
                    .foregroundColor(.textSecondary)
                    .opacity(isHovering ? 1 : .opacityStrong)
                    .animation(.uiFast, value: isHovering)
                    .frame(width: .spacing3)
                    .accessibilityHidden(true)

                // Visibility toggle
                Button(action: {
                    documentState.toggleLayerVisibility(id: layer.id)
                }) {
                    Image(systemName: layer.isVisible ? "eye.fill" : "eye.slash")
                        .font(.system(size: .iconSmall))
                        .foregroundColor(layer.isVisible ? Color.statusVisible : Color.statusHidden)
                        .frame(width: .controlSmall, height: .controlSmall)
                }
                .buttonStyle(.borderless)
                .help(layer.isVisible ? "Hide Layer" : "Show Layer")
                .accessibilityLabel(layer.isVisible ? "Hide layer \(layer.name)" : "Show layer \(layer.name)")

                // Thumbnail (placeholder)
                RoundedRectangle(cornerRadius: .radiusXSmall)
                    .fill(
                        LinearGradient(
                            colors: [Color.accentMedium, Color.accentLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: .spacing8, height: .spacing8)
                    .overlay {
                        Image(systemName: "square.on.square.dashed")
                            .font(.system(size: .iconSmall))
                            .foregroundColor(.textSecondary.opacity(.opacityHigh))
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: .radiusXSmall)
                            .strokeBorder(Color.borderDefault.opacity(.opacityLight), lineWidth: .lineHairline)
                    )
                    .shadowSubtle()
                    .accessibilityHidden(true)

                // Layer name
                VStack(alignment: .leading, spacing: .spacing1) {
                    Text(layer.name)
                        .font(.bodyEmphasis)
                        .lineLimit(1)

                    Text("\(layer.stitches.count) stitch group\(layer.stitches.count == 1 ? "" : "s")")
                        .font(.captionSmall)
                        .foregroundColor(.textSecondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(layer.name), \(layer.stitches.count) stitch groups")

                Spacer(minLength: .spacing1)

                // Opacity indicator
                if showOpacity || isHovering {
                    Text("\(Int(layer.opacity * 100))%")
                        .font(.mono)
                        .foregroundColor(.textSecondary)
                        .frame(width: .spacing10, alignment: .trailing)
                        .onTapGesture {
                            withAnimation(.springQuick) {
                                showOpacity.toggle()
                            }
                        }
                        .accessibilityLabel("Layer opacity \(Int(layer.opacity * 100)) percent")
                        .accessibilityHint("Tap to toggle opacity slider")
                }

                // Lock toggle
                Button(action: {
                    documentState.toggleLayerLock(id: layer.id)
                }) {
                    Image(systemName: layer.isLocked ? "lock.fill" : "lock.open")
                        .font(.system(size: .iconSmall))
                        .foregroundColor(layer.isLocked ? Color.statusLocked : Color.textSecondary.opacity(.opacityMuted))
                        .frame(width: .controlSmall, height: .controlSmall)
                }
                .buttonStyle(.borderless)
                .help(layer.isLocked ? "Unlock Layer" : "Lock Layer")
                .opacity(isHovering || layer.isLocked ? 1 : 0)
                .accessibilityLabel(layer.isLocked ? "Unlock layer \(layer.name)" : "Lock layer \(layer.name)")
            }
            .padding(.horizontal, .spacing2_5)
            .padding(.vertical, .spacing2)
            .background(
                RoundedRectangle(cornerRadius: .radiusSmall)
                    .fill(isSelected ? Color.interactiveSelected : (isHovering ? Color.interactiveHover : Color.clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: .radiusSmall)
                    .strokeBorder(isSelected ? Color.borderFocus : Color.clear, lineWidth: .lineStandard)
            )

            // Opacity slider (shown when clicked)
            if showOpacity {
                HStack(spacing: .spacing2_5) {
                    Text("Opacity:")
                        .font(.labelSemibold)
                        .foregroundColor(.textSecondary)
                        .frame(width: .spacing12, alignment: .leading)

                    Slider(value: opacityBinding, in: 0...1)
                        .controlSize(.small)
                        .tint(.accentColor)

                    Text("\(Int(layer.opacity * 100))%")
                        .font(.captionSmallMedium)
                        .foregroundColor(.textPrimary)
                        .frame(width: .spacing8, alignment: .trailing)
                }
                .padding(.horizontal, .spacing3)
                .padding(.vertical, .spacing1_5)
                .background(Color.surfaceSecondary.opacity(.opacityMedium))
                .cornerRadius(.radiusSmall)
                .padding(.horizontal, .spacing1_5)
                .padding(.bottom, .spacing1)
                .transition(.move(edge: .top).combined(with: .opacity))
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Opacity slider")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            documentState.selectedLayerID = layer.id
        }
        .onHover { hovering in
            withAnimation(.uiFast) {
                isHovering = hovering
            }
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
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
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
