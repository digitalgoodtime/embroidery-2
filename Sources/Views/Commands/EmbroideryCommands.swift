//
//  EmbroideryCommands.swift
//  EmbroideryStudio
//
//  Menu bar commands organized like Hatch/Photoshop
//

import SwiftUI

struct EmbroideryCommands: Commands {
    var body: some Commands {
        // File menu additions
        CommandGroup(after: .newItem) {
            Divider()

            Button("Import Design...") {
                // TODO: Import embroidery design
                print("Import design")
            }
            .keyboardShortcut("i", modifiers: [.command])

            Button("Import Image...") {
                // TODO: Import image for auto-digitize
                print("Import image")
            }
            .keyboardShortcut("i", modifiers: [.command, .shift])

            Menu("Export As") {
                Button("PES Format...") { print("Export PES") }
                Button("DST Format...") { print("Export DST") }
                Button("JEF Format...") { print("Export JEF") }
                Button("PNG Image...") { print("Export PNG") }
                Button("PDF Document...") { print("Export PDF") }
            }
        }

        // Edit menu
        CommandMenu("Edit") {
            Button("Undo") {
                // TODO: Implement undo
            }
            .keyboardShortcut("z", modifiers: .command)

            Button("Redo") {
                // TODO: Implement redo
            }
            .keyboardShortcut("z", modifiers: [.command, .shift])

            Divider()

            Button("Cut") {
                // TODO: Implement cut
            }
            .keyboardShortcut("x", modifiers: .command)

            Button("Copy") {
                // TODO: Implement copy
            }
            .keyboardShortcut("c", modifiers: .command)

            Button("Paste") {
                // TODO: Implement paste
            }
            .keyboardShortcut("v", modifiers: .command)

            Divider()

            Button("Select All") {
                // TODO: Select all objects
            }
            .keyboardShortcut("a", modifiers: .command)

            Button("Deselect All") {
                // TODO: Deselect all
            }
            .keyboardShortcut("d", modifiers: .command)
        }

        // Digitize menu
        CommandMenu("Digitize") {
            Button("Auto-Digitize Image...") {
                // TODO: Auto-digitize
            }
            .keyboardShortcut("a", modifiers: [.command, .option])

            Button("Manual Digitize") {
                // TODO: Activate manual digitize tool
            }
            .keyboardShortcut("d", modifiers: [.command, .option])

            Divider()

            Menu("Stitch Type") {
                Button("Running Stitch") { print("Running stitch") }
                Button("Satin Stitch") { print("Satin stitch") }
                Button("Fill Stitch") { print("Fill stitch") }
                Button("Appliqué") { print("Appliqué") }
            }

            Divider()

            Button("Fabric Assist...") {
                // TODO: Show fabric assist dialog
            }
        }

        // Text menu
        CommandMenu("Text") {
            Button("Add Text...") {
                // TODO: Add text
            }
            .keyboardShortcut("t", modifiers: .command)

            Button("Add Monogram...") {
                // TODO: Add monogram
            }
            .keyboardShortcut("m", modifiers: .command)

            Divider()

            Menu("Font") {
                Button("Browse Embroidery Fonts...") { print("Browse fonts") }
            }
        }

        // View menu
        CommandMenu("View") {
            Button("Zoom In") {
                // TODO: Zoom in
            }
            .keyboardShortcut("+", modifiers: .command)

            Button("Zoom Out") {
                // TODO: Zoom out
            }
            .keyboardShortcut("-", modifiers: .command)

            Button("Zoom to Fit") {
                // TODO: Zoom to fit
            }
            .keyboardShortcut("0", modifiers: .command)

            Button("Actual Size") {
                // TODO: Zoom to 100%
            }
            .keyboardShortcut("1", modifiers: .command)

            Divider()

            Toggle("Show Grid", isOn: .constant(true))
                .keyboardShortcut("'", modifiers: .command)

            Toggle("Show Hoop", isOn: .constant(true))
                .keyboardShortcut("h", modifiers: .command)

            Toggle("Show Rulers", isOn: .constant(true))
                .keyboardShortcut("r", modifiers: .command)

            Toggle("Snap to Grid", isOn: .constant(false))
                .keyboardShortcut(";", modifiers: .command)

            Divider()

            Toggle("Show Layers Panel", isOn: .constant(true))
                .keyboardShortcut("1", modifiers: [.command, .option])

            Toggle("Show Tools Panel", isOn: .constant(true))
                .keyboardShortcut("2", modifiers: [.command, .option])
        }

        // Layers menu
        CommandMenu("Layers") {
            Button("New Layer") {
                // TODO: Add new layer
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])

            Button("Duplicate Layer") {
                // TODO: Duplicate layer
            }
            .keyboardShortcut("j", modifiers: .command)

            Button("Delete Layer") {
                // TODO: Delete layer
            }

            Divider()

            Button("Merge Down") {
                // TODO: Merge layers
            }
            .keyboardShortcut("e", modifiers: .command)

            Button("Merge Visible") {
                // TODO: Merge visible layers
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])

            Divider()

            Button("Show/Hide Layer") {
                // TODO: Toggle layer visibility
            }

            Button("Lock/Unlock Layer") {
                // TODO: Toggle layer lock
            }
        }

        // Stitch menu
        CommandMenu("Stitch") {
            Button("Play Stitch Sequence") {
                // TODO: Play stitches
            }
            .keyboardShortcut(" ", modifiers: [])

            Button("Stop Playback") {
                // TODO: Stop playback
            }
            .keyboardShortcut(".", modifiers: .command)

            Divider()

            Button("Step Forward") {
                // TODO: Step forward
            }
            .keyboardShortcut(.rightArrow, modifiers: [])

            Button("Step Backward") {
                // TODO: Step backward
            }
            .keyboardShortcut(.leftArrow, modifiers: [])

            Divider()

            Menu("Playback Speed") {
                Button("0.5x") { print("Speed 0.5x") }
                Button("1x") { print("Speed 1x") }
                Button("2x") { print("Speed 2x") }
                Button("5x") { print("Speed 5x") }
            }

            Divider()

            Button("Optimize Stitches") {
                // TODO: Optimize stitch order
            }

            Button("Calculate Stitch Count") {
                // TODO: Calculate stats
            }
        }

        // Help menu additions
        CommandGroup(after: .help) {
            Button("EmbroideryStudio Help") {
                // TODO: Show help
            }
            .keyboardShortcut("/", modifiers: .command)

            Divider()

            Button("Tutorials...") {
                // TODO: Show tutorials
            }

            Button("Keyboard Shortcuts...") {
                // TODO: Show shortcuts
            }
        }
    }
}
