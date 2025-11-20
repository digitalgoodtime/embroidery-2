//
//  DocumentView.swift
//  EmbroideryStudio
//
//  Main document view with Photoshop-inspired layout and Liquid Glass design
//

import SwiftUI

struct DocumentView: View {
    @Binding var document: EmbroideryDocument
    @StateObject private var documentState: DocumentState
    @StateObject private var toolManager = ToolManager.shared

    // Sidebar state
    @State private var showLayersSidebar = true
    @State private var showPropertiesSidebar = true
    @State private var layersSidebarWidth: CGFloat = .sidebarDefaultWidth
    @State private var propertiesSidebarWidth: CGFloat = .propertiesSidebarDefaultWidth

    init(document: Binding<EmbroideryDocument>) {
        self._document = document
        self._documentState = StateObject(wrappedValue: DocumentState(document: document.wrappedValue))
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Tool Palette (always visible)
                ToolPalette()

                // Layers Sidebar
                if showLayersSidebar {
                    LayersSidebar(documentState: documentState)
                        .frame(width: layersSidebarWidth)
                        .background(.ultraThinMaterial)

                    ResizableDivider { delta in
                        let newWidth = layersSidebarWidth + delta
                        layersSidebarWidth = max(.sidebarMinWidth, min(.sidebarMaxWidth, newWidth))
                    }
                }

                // Center - Canvas
                VStack(spacing: 0) {
                    // Top Toolbar
                    TopToolbar(documentState: documentState)
                        .frame(height: .toolbarHeight)

                    // Canvas
                    CanvasView(documentState: documentState)
                        .background(Color.surfaceCanvas)

                    // Bottom Status Bar
                    StatusBar(documentState: documentState)
                        .frame(height: .statusBarHeight)
                }

                // Properties Sidebar
                if showPropertiesSidebar {
                    ResizableDivider { delta in
                        let newWidth = propertiesSidebarWidth - delta
                        propertiesSidebarWidth = max(.sidebarMinWidth, min(.sidebarMaxWidth, newWidth))
                    }

                    PropertiesSidebar(documentState: documentState)
                        .frame(width: propertiesSidebarWidth)
                        .background(.ultraThinMaterial)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    withAnimation(.uiSlow) {
                        showLayersSidebar.toggle()
                    }
                }) {
                    Image(systemName: "sidebar.left")
                }
                .help("Toggle Layers Panel (⌘⌥1)")
                .accessibilityLabel(showLayersSidebar ? "Hide layers panel" : "Show layers panel")
            }

            ToolbarItem(placement: .automatic) {
                Button(action: {
                    withAnimation(.uiSlow) {
                        showPropertiesSidebar.toggle()
                    }
                }) {
                    Image(systemName: "sidebar.right")
                }
                .help("Toggle Properties Panel (⌘⌥2)")
                .accessibilityLabel(showPropertiesSidebar ? "Hide properties panel" : "Show properties panel")
            }
        }
        .onChange(of: documentState.document) { newValue in
            document = newValue
        }
    }
}

#Preview {
    DocumentView(document: .constant(EmbroideryDocument()))
}
