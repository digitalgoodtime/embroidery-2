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
    @State private var cursorPushed = false

    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: .spacing2)
            .overlay {
                Rectangle()
                    .fill(isHovering || isDragging ? Color.accentStrong : Color.clear)
                    .frame(width: .lineStandard)
                    .animation(.uiFast, value: isHovering)
                    .animation(.uiFast, value: isDragging)
            }
            .contentShape(Rectangle())
            .onHover { hovering in
                isHovering = hovering
                if hovering && !cursorPushed {
                    NSCursor.resizeLeftRight.push()
                    cursorPushed = true
                } else if !hovering && !isDragging && cursorPushed {
                    NSCursor.pop()
                    cursorPushed = false
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            if !cursorPushed {
                                NSCursor.resizeLeftRight.push()
                                cursorPushed = true
                            }
                        }
                        onDrag(value.translation.width)
                    }
                    .onEnded { _ in
                        isDragging = false
                        if !isHovering && cursorPushed {
                            NSCursor.pop()
                            cursorPushed = false
                        }
                    }
            )
            .accessibilityLabel("Resize panel divider")
            .accessibilityHint("Drag to resize the panel width")
            .accessibilityAddTraits(.isButton)
    }
}
