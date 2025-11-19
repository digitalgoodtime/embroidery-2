# EmbroideryStudio

A professional embroidery design application for macOS, inspired by Hatch Embroidery and designed with the polish of Pixelmator Pro.

## Overview

EmbroideryStudio is built to provide a native, high-quality macOS experience for embroidery design. The application focuses on clean architecture, extensibility, and professional UI/UX.

## Design Principles

- **Pixelmator Pro-inspired UI**: Single-window interface with canvas-first design, translucent panels, and native macOS controls
- **Photoshop-inspired Tool Organization**: Logical tool grouping and keyboard shortcuts
- **Hatch-inspired Features**: Comprehensive embroidery-specific features including auto-digitizing, stitch player, and fabric assist

## Architecture

### Project Structure

```
Sources/
├── EmbroideryStudioApp.swift          # App entry point
├── Core/
│   ├── Document/
│   │   └── EmbroideryDocument.swift   # Document model
│   └── Architecture/
│       ├── Protocols.swift            # Core protocols (Tool, Panel, etc.)
│       ├── ToolManager.swift          # Tool management system
│       └── DocumentState.swift        # Document state management
├── Tools/
│   ├── SelectionTool.swift
│   ├── AutoDigitizeTool.swift
│   ├── ManualDigitizeTool.swift
│   ├── TextTool.swift
│   ├── ShapeTool.swift
│   └── ZoomTool.swift
├── Views/
│   ├── DocumentView.swift             # Main document view
│   ├── Canvas/
│   │   └── CanvasView.swift          # Canvas with grid, hoop, layers
│   ├── Sidebars/
│   │   ├── LayersSidebar.swift       # Layers panel (left)
│   │   └── ToolsSidebar.swift        # Tools panel (right)
│   ├── Toolbars/
│   │   └── TopToolbar.swift          # Top toolbar
│   ├── Commands/
│   │   └── EmbroideryCommands.swift  # Menu bar commands
│   └── Settings/
│       └── SettingsView.swift        # Settings window
└── Assets.xcassets/                   # App icons and resources
```

### Key Components

#### Document Model
- **EmbroideryDocument**: FileDocument-based model with layers, canvas, and metadata
- **Canvas**: Configurable workspace with hoop sizes and grid
- **Layers**: Hierarchical organization of stitch groups
- **Stitch System**: Support for running, satin, fill, and appliqué stitches

#### Architecture Patterns
- **Protocol-Oriented**: Extensible tool system via `Tool` protocol
- **Observable Objects**: SwiftUI state management with `@ObservedObject` and `@StateObject`
- **Singleton Managers**: Shared `ToolManager` for global tool state
- **Document-Based**: Native macOS document architecture

#### Tool System
- **Extensible**: Add new tools by conforming to `Tool` protocol
- **Category-Based**: Tools organized by category (Selection, Digitizing, Text, etc.)
- **Keyboard Shortcuts**: Built-in shortcut support
- **Mouse Handling**: Protocol methods for mouse down/drag/up events

## Features (Current Status: Placeholder/NOOP)

All features are implemented as placeholders with proper UI/UX and architecture, ready for actual implementation:

### Digitizing
- ✓ Auto-Digitize tool structure
- ✓ Manual digitize tool structure
- ✓ Stitch type support (running, satin, fill, appliqué)
- ✓ Fabric Assist system placeholder

### Text & Monograms
- ✓ Text tool structure
- ✓ Font system placeholder
- ✓ Monogram support placeholder

### Stitch Player
- ✓ Playback controls UI
- ✓ Speed control
- ✓ Step forward/backward
- ✓ Statistics display

### Layers
- ✓ Layer creation/deletion
- ✓ Layer visibility/lock toggles
- ✓ Layer duplication
- ✓ Layer selection

### Canvas
- ✓ Zoom in/out/fit
- ✓ Grid display
- ✓ Hoop display
- ✓ Ruler support (placeholder)
- ✓ Pan and zoom gestures

### Export
- ✓ Multiple format support structure (PES, DST, JEF, PNG, PDF)
- ✓ Export options UI

## Building the Project

### Requirements
- macOS 13.0+
- Xcode 15.0+
- XcodeGen

### Setup

1. Install XcodeGen:
```bash
brew install xcodegen
```

2. Generate Xcode project:
```bash
xcodegen generate
```

3. Open the project:
```bash
open EmbroideryStudio.xcodeproj
```

4. Build and run (⌘R)

## Project Configuration

The project uses XcodeGen for project file generation. Configuration is in `project.yml`:

- **Target**: macOS 13.0+
- **Language**: Swift 5.9
- **Frameworks**: SwiftUI, AppKit, Metal, MetalKit
- **App Sandbox**: Enabled with file access
- **Hardened Runtime**: Enabled

## UI/UX Highlights

### Layout (Pixelmator Pro Style)
- **Center**: Canvas with grid and hoop visualization
- **Left Sidebar**: Layers panel with thumbnails and controls
- **Right Sidebar**: Tools panel with tabbed interface (Tools/Properties/Stitch Player)
- **Top**: Toolbar with quick actions and view controls
- **Bottom**: Status bar with tool info and document stats

### Native macOS Features
- **Dark Mode**: Automatic dark appearance
- **Translucent Materials**: `.ultraThinMaterial` backgrounds
- **SF Symbols**: Native icon system
- **Keyboard Shortcuts**: Comprehensive shortcut support
- **Menu Bar**: Full menu organization
- **Document-Based**: Native file handling

### Design Details
- **Monospace Fonts**: For numeric displays (zoom, stitch count)
- **Grouped Forms**: Native settings interface
- **Context Menus**: Right-click support (ready for implementation)
- **Hover States**: Button highlighting on hover
- **Selection Feedback**: Visual feedback for selected tools/layers

## Next Steps for Implementation

### Phase 1: Core Functionality
1. Implement actual stitch generation algorithms
2. Add real auto-digitize with image processing
3. Implement undo/redo system
4. Add file import/export for standard formats

### Phase 2: Advanced Features
1. Implement Fabric Assist logic
2. Add real-time stitch rendering
3. Implement stitch player animation
4. Add thread color management

### Phase 3: Polish
1. Add custom app icon
2. Implement preferences persistence
3. Add tutorials and help system
4. Performance optimization

## Keyboard Shortcuts

### Tools
- `V` - Selection Tool
- `A` - Auto Digitize
- `D` - Manual Digitize
- `T` - Text Tool
- `S` - Shape Tool
- `Z` - Zoom Tool

### View
- `⌘+` - Zoom In
- `⌘-` - Zoom Out
- `⌘0` - Zoom to Fit
- `⌘'` - Toggle Grid
- `⌘H` - Toggle Hoop
- `⌘R` - Toggle Rulers

### Layers
- `⌘⇧N` - New Layer
- `⌘J` - Duplicate Layer
- `⌘E` - Merge Down

### File
- `⌘I` - Import Design
- `⌘⇧I` - Import Image

## Code Style

- **SwiftUI-First**: Prefer SwiftUI over AppKit where possible
- **Protocol-Oriented**: Use protocols for extensibility
- **Value Types**: Prefer structs over classes
- **Observable Pattern**: Use `@Published` and `@ObservedObject`
- **Documentation**: Document all public APIs
- **Organization**: Group related files in folders

## Contributing

This is a foundational implementation. All features are structured and ready for implementation. The architecture supports easy addition of new:
- Tools (conform to `Tool` protocol)
- Export formats (conform to `ExportFormat` protocol)
- Import formats (conform to `ImportFormat` protocol)
- Stitch generators (conform to `StitchGenerator` protocol)

## License

[License to be determined]
