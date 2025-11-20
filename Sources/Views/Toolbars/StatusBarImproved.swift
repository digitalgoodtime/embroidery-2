//
//  StatusBarImproved.swift
//  EmbroideryStudio
//
//  Enhanced status bar with better information display
//

import SwiftUI

extension StatusBar {
    var improvedBody: some View {
        HStack(spacing: 16) {
            // Current tool
            if let tool = toolManager.selectedTool {
                HStack(spacing: 6) {
                    Image(systemName: tool.icon)
                        .foregroundColor(.accentColor)
                    Text(tool.name)
                        .font(.system(.caption, design: .rounded))
                }
            }

            Divider()
                .frame(height: 16)

            // Cursor position / selection info
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Text("Ready")
                    .font(.caption)
            }
            .foregroundColor(.secondary)

            Spacer()

            // Layer info
            if let selectedID = documentState.selectedLayerID,
               let layer = documentState.document.layers.first(where: { $0.id == selectedID }) {
                HStack(spacing: 6) {
                    Image(systemName: layer.isVisible ? "eye.fill" : "eye.slash")
                        .font(.system(size: 10))
                        .foregroundColor(layer.isVisible ? .secondary : .red)
                    Text(layer.name)
                        .font(.system(.caption, design: .rounded))
                    
                    if layer.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                    }
                }
                .foregroundColor(.secondary)
            } else {
                Text("No layer selected")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
        .padding(.horizontal, 12)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.95))
    }
}
