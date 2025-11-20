//
//  DocumentView.swift
//  EmbroideryStudio
//
//  Main document view with Photoshop-inspired layout
//

import SwiftUI

struct DocumentView: View {
    @Binding var document: EmbroideryDocument
    @StateObject private var documentState: DocumentState
    @StateObject private var toolManager = ToolManager.shared

    // Sidebar state
    @State private var showLayersSidebar = true
    @State private var showPropertiesSidebar = true
    @State private var layersSidebarWidth: CGFloat = 250
    @State private var propertiesSidebarWidth: CGFloat = 280

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
                        layersSidebarWidth = max(200, min(400, newWidth))
                    }
                }

                // Center - Canvas
                VStack(spacing: 0) {
                    // Top Toolbar
                    TopToolbar(documentState: documentState)
                        .frame(height: 44)

                    // Canvas
                    CanvasView(documentState: documentState)
                        .background(Color(nsColor: .windowBackgroundColor))

                    // Bottom Status Bar
                    StatusBar(documentState: documentState)
                        .frame(height: 28)
                }

                // Properties Sidebar
                if showPropertiesSidebar {
                    ResizableDivider { delta in
                        let newWidth = propertiesSidebarWidth - delta
                        propertiesSidebarWidth = max(200, min(400, newWidth))
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
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showLayersSidebar.toggle()
                    }
                }) {
                    Image(systemName: "sidebar.left")
                }
                .help("Toggle Layers Panel (⌘⌥1)")
            }

            ToolbarItem(placement: .automatic) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showPropertiesSidebar.toggle()
                    }
                }) {
                    Image(systemName: "sidebar.right")
                }
                .help("Toggle Properties Panel (⌘⌥2)")
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
