//
//  ResizableDivider.swift
//  EmbroideryStudio
//
//  Draggable divider for resizing panels
//

import SwiftUI

struct ResizableDivider: View {
    let onDrag: (CGFloat) -> Void

    @State private var isHovering = false
    @State private var isDragging = false

    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: 8)
            .overlay {
                Rectangle()
                    .fill(isHovering || isDragging ? Color.accentColor.opacity(0.5) : Color.clear)
                    .frame(width: 1)
            }
            .contentShape(Rectangle())
            .onHover { hovering in
                isHovering = hovering
                if hovering {
                    NSCursor.resizeLeftRight.push()
                } else if !isDragging {
                    NSCursor.pop()
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            NSCursor.resizeLeftRight.push()
                        }
                        onDrag(value.translation.width)
                    }
                    .onEnded { _ in
                        isDragging = false
                        NSCursor.pop()
                        if !isHovering {
                            NSCursor.pop()
                        }
                    }
            )
    }
}
