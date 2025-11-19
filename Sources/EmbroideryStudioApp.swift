//
//  EmbroideryStudioApp.swift
//  EmbroideryStudio
//
//  Main application entry point
//

import SwiftUI

@main
struct EmbroideryStudioApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        DocumentGroup(newDocument: { EmbroideryDocument() }) { file in
            DocumentView(document: file.$document)
        }
        .commands {
            EmbroideryCommands()
        }

        // Settings window
        Settings {
            SettingsView()
        }
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configure app appearance
        setupAppearance()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    private func setupAppearance() {
        // Set up native macOS appearance preferences
        if let appearance = NSAppearance(named: .darkAqua) {
            NSApp.appearance = appearance
        }
    }
}
