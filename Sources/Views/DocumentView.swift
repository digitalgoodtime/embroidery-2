//
//  DocumentView.swift
//  EmbroideryStudio
//
//  Main document view with Pixelmator Pro-inspired layout
//

import SwiftUI

struct DocumentView: View {
    @Binding var document: EmbroideryDocument
    @StateObject private var documentState: DocumentState
    @StateObject private var toolManager = ToolManager.shared

    // Sidebar state
    @State private var showLeftSidebar = true
    @State private var showRightSidebar = true
    @State private var leftSidebarWidth: CGFloat = 250
    @State private var rightSidebarWidth: CGFloat = 250

    init(document: Binding<EmbroideryDocument>) {
        self._document = document
        self._documentState = StateObject(wrappedValue: DocumentState(document: document.wrappedValue))
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left Sidebar - Layers Panel
                if showLeftSidebar {
                    LayersSidebar(documentState: documentState)
                        .frame(width: leftSidebarWidth)
                        .background(.ultraThinMaterial)

                    ResizableDivider { delta in
                        let newWidth = leftSidebarWidth + delta
                        leftSidebarWidth = max(200, min(400, newWidth))
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

                // Right Sidebar - Tools Panel
                if showRightSidebar {
                    ResizableDivider { delta in
                        let newWidth = rightSidebarWidth - delta
                        rightSidebarWidth = max(200, min(400, newWidth))
                    }

                    ToolsSidebar(documentState: documentState)
                        .frame(width: rightSidebarWidth)
                        .background(.ultraThinMaterial)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showLeftSidebar.toggle()
                    }
                }) {
                    Image(systemName: "sidebar.left")
                }
                .help("Toggle Layers Panel (⌘⌥1)")
            }

            ToolbarItem(placement: .automatic) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showRightSidebar.toggle()
                    }
                }) {
                    Image(systemName: "sidebar.right")
                }
                .help("Toggle Tools Panel (⌘⌥2)")
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
