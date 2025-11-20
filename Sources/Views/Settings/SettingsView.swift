//
//  SettingsView.swift
//  EmbroideryStudio
//
//  Application settings window with liquid glass polish
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .general

    enum SettingsTab: String, CaseIterable, Identifiable {
        case general = "General"
        case canvas = "Canvas"
        case stitch = "Stitch"
        case export = "Export"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .general: return "gear"
            case .canvas: return "square.on.square.dashed"
            case .stitch: return "thread.fill"
            case .export: return "square.and.arrow.up"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(SettingsTab.allCases) { tab in
                settingsView(for: tab)
                    .tabItem {
                        Label(tab.rawValue, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
        .frame(width: 500, height: 400)
    }

    @ViewBuilder
    private func settingsView(for tab: SettingsTab) -> some View {
        Form {
            switch tab {
            case .general:
                GeneralSettingsView()
            case .canvas:
                CanvasSettingsView()
            case .stitch:
                StitchSettingsView()
            case .export:
                ExportSettingsView()
            }
        }
        .formStyle(.grouped)
        .padding(.spacing3)
    }
}

// MARK: - General Settings

struct GeneralSettingsView: View {
    var body: some View {
        Section("Appearance") {
            Picker("Theme:", selection: .constant("Auto")) {
                Text("Auto").tag("Auto")
                Text("Light").tag("Light")
                Text("Dark").tag("Dark")
            }
            .font(.label)

            Toggle("Show welcome screen on launch", isOn: .constant(true))
                .font(.label)
        }

        Section("Autosave") {
            Toggle("Enable autosave", isOn: .constant(true))
                .font(.label)

            Picker("Autosave interval:", selection: .constant(5)) {
                Text("1 minute").tag(1)
                Text("5 minutes").tag(5)
                Text("10 minutes").tag(10)
                Text("30 minutes").tag(30)
            }
            .font(.label)
        }
    }
}

// MARK: - Canvas Settings

struct CanvasSettingsView: View {
    var body: some View {
        Section("Default Canvas") {
            Picker("Hoop size:", selection: .constant(EmbroideryCanvas.HoopSize.standard4x4)) {
                ForEach(EmbroideryCanvas.HoopSize.allCases, id: \.self) { size in
                    Text(size.rawValue).tag(size)
                }
            }
            .font(.label)

            Toggle("Show grid by default", isOn: .constant(true))
                .font(.label)
            Toggle("Show hoop by default", isOn: .constant(true))
                .font(.label)
            Toggle("Show rulers by default", isOn: .constant(true))
                .font(.label)
        }

        Section("Grid") {
            Picker("Grid size:", selection: .constant(10.0)) {
                Text("5mm").tag(5.0)
                Text("10mm").tag(10.0)
                Text("20mm").tag(20.0)
            }
            .font(.label)

            Toggle("Snap to grid", isOn: .constant(false))
                .font(.label)
        }
    }
}

// MARK: - Stitch Settings

struct StitchSettingsView: View {
    var body: some View {
        Section("Default Stitch Properties") {
            VStack(alignment: .leading, spacing: .spacing2) {
                HStack {
                    Text("Density:")
                        .font(.label)
                    Spacer()
                    Text("4.0 st/mm")
                        .font(.mono)
                        .foregroundColor(.textSecondary)
                        .frame(width: .spacing20, alignment: .trailing)
                }

                Slider(value: .constant(4.0), in: 1.0...10.0)
                    .controlSize(.small)
                    .tint(.accentColor)
            }

            Toggle("Enable Fabric Assist", isOn: .constant(true))
                .font(.label)
        }

        Section("Stitch Player") {
            VStack(alignment: .leading, spacing: .spacing2) {
                HStack {
                    Text("Default speed:")
                        .font(.label)
                    Spacer()
                    Text("1.0x")
                        .font(.mono)
                        .foregroundColor(.textSecondary)
                        .frame(width: .spacing12 + .spacing3, alignment: .trailing)
                }

                Slider(value: .constant(1.0), in: 0.1...5.0)
                    .controlSize(.small)
                    .tint(.accentColor)
            }

            Toggle("Auto-play on open", isOn: .constant(false))
                .font(.label)
        }
    }
}

// MARK: - Export Settings

struct ExportSettingsView: View {
    var body: some View {
        Section("Default Export Format") {
            Picker("Format:", selection: .constant("PES")) {
                Text("PES").tag("PES")
                Text("DST").tag("DST")
                Text("JEF").tag("JEF")
            }
            .font(.label)
        }

        Section("Export Options") {
            Toggle("Include color information", isOn: .constant(true))
                .font(.label)
            Toggle("Optimize stitch order", isOn: .constant(true))
                .font(.label)
            Toggle("Trim jump stitches", isOn: .constant(true))
                .font(.label)
        }
    }
}
