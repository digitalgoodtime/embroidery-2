# EmbroideryStudio Architecture Guide

## Overview

EmbroideryStudio is built with a clean, extensible architecture inspired by modern Mac applications like Pixelmator Pro and professional tools like Photoshop and Hatch Embroidery.

## Core Principles

### 1. Protocol-Oriented Design

The application uses protocols to define contracts for extensibility:

```swift
protocol Tool: Identifiable {
    var id: String { get }
    var name: String { get }
    var icon: String { get }
    var category: ToolCategory { get }

    func activate()
    func deactivate()
    func handleMouseDown(at point: CGPoint)
    func handleMouseDragged(to point: CGPoint)
    func handleMouseUp(at point: CGPoint)
}
```

**Benefits:**
- Easy to add new tools without modifying existing code
- Type-safe tool registration
- Consistent interface across all tools

### 2. Document-Based Architecture

Uses Apple's native `FileDocument` protocol:

```swift
struct EmbroideryDocument: FileDocument {
    var canvas: Canvas
    var layers: [EmbroideryLayer]
    var metadata: DocumentMetadata
}
```

**Benefits:**
- Automatic file handling (open, save, save as)
- iCloud support ready
- Autosave support
- Version browsing support

### 3. State Management

Uses SwiftUI's observable pattern:

```swift
class DocumentState: ObservableObject {
    @Published var document: EmbroideryDocument
    @Published var selectedLayerID: UUID?
    @Published var zoomLevel: Double = 1.0
    // ...
}
```

**Benefits:**
- Reactive UI updates
- Single source of truth
- Predictable state changes

## Component Architecture

### Tool System

```
ToolManager (Singleton)
    ├── Available Tools
    │   ├── SelectionTool
    │   ├── AutoDigitizeTool
    │   ├── ManualDigitizeTool
    │   ├── TextTool
    │   ├── ShapeTool
    │   └── ZoomTool
    └── Selected Tool
```

**Adding a New Tool:**

1. Create a new file in `Sources/Tools/`
2. Conform to `Tool` protocol
3. Register in `ToolManager.registerDefaultTools()`

Example:
```swift
struct MyNewTool: Tool {
    let id = "my-tool"
    let name = "My Tool"
    let icon = "star.fill"
    let tooltip = "My custom tool (M)"
    let category = ToolCategory.editing
    let keyboardShortcut: KeyEquivalent? = "m"

    func activate() {
        // Setup when tool is selected
    }

    func handleMouseDown(at point: CGPoint) {
        // Handle click
    }
}
```

### View Hierarchy

```
DocumentView (Root)
    ├── LayersSidebar (Left)
    │   └── LayerRow (per layer)
    ├── Center Column
    │   ├── TopToolbar
    │   ├── CanvasView
    │   │   ├── GridView
    │   │   ├── HoopView
    │   │   └── LayerView (per layer)
    │   └── StatusBar
    └── ToolsSidebar (Right)
        ├── ToolsPanelView
        ├── PropertiesPanelView
        └── StitchPlayerPanelView
```

### Data Flow

```
User Action
    ↓
Tool/Command
    ↓
DocumentState (ObservableObject)
    ↓
Document Mutation
    ↓
SwiftUI View Update
```

## Design Patterns

### 1. Singleton Pattern

**Where:** `ToolManager`

**Why:** Global tool state needs to be shared across all views

```swift
class ToolManager: ObservableObject {
    static let shared = ToolManager()
    private init() { }
}
```

### 2. Strategy Pattern

**Where:** Tool system

**Why:** Different tools have different behaviors but share the same interface

```swift
protocol Tool {
    func handleMouseDown(at point: CGPoint)
}
```

### 3. Observer Pattern

**Where:** State management

**Why:** Views need to react to state changes

```swift
@ObservedObject var documentState: DocumentState
```

### 4. Command Pattern (Ready for Implementation)

**Where:** Undo/Redo system

**Why:** Encapsulate actions for undo/redo

```swift
protocol EmbroideryCommand {
    func execute()
    func undo()
}
```

## File Organization

### Grouping Strategy

```
Sources/
├── Core/               # Core business logic
│   ├── Document/       # Data models
│   └── Architecture/   # Protocols, managers
├── Tools/              # Tool implementations
├── Views/              # SwiftUI views
│   ├── Canvas/         # Canvas-related views
│   ├── Sidebars/       # Panel views
│   ├── Toolbars/       # Toolbar views
│   ├── Commands/       # Menu commands
│   └── Settings/       # Settings views
└── Assets.xcassets/    # Visual assets
```

### Naming Conventions

- **Files:** PascalCase, descriptive (`AutoDigitizeTool.swift`)
- **Types:** PascalCase (`EmbroideryDocument`, `Tool`)
- **Properties:** camelCase (`selectedTool`, `zoomLevel`)
- **Functions:** camelCase, verb-based (`addLayer`, `zoomIn`)
- **Constants:** camelCase or ALL_CAPS for true constants

## Extensibility Points

### Adding New Stitch Types

1. Add case to `StitchType` enum
2. Implement generator conforming to `StitchGenerator`
3. Add UI in properties panel

### Adding Export Formats

1. Conform to `ExportFormat` protocol
2. Implement `export(document:)` method
3. Register in export menu

Example:
```swift
struct PESExporter: ExportFormat {
    let name = "PES"
    let fileExtension = "pes"
    let description = "Brother/Babylock embroidery format"

    func export(document: EmbroideryDocument) throws -> Data {
        // Generate PES file
    }
}
```

### Adding Import Formats

1. Conform to `ImportFormat` protocol
2. Implement `import(data:)` method
3. Register in import menu

### Adding Panels

1. Conform to `SidebarPanel` protocol
2. Create SwiftUI view
3. Add to sidebar tab picker

## Performance Considerations

### Current Implementation

- **Canvas Rendering:** Uses SwiftUI `Canvas` for hardware-accelerated drawing
- **Layer System:** Lazy rendering, only visible layers drawn
- **Stitch Rendering:** Currently placeholder, ready for Metal implementation

### Future Optimizations

1. **Metal Rendering:** Direct GPU rendering for complex designs
2. **Level of Detail:** Reduce stitch complexity at low zoom levels
3. **Viewport Culling:** Only render visible portions
4. **Background Processing:** Async stitch generation

## Testing Strategy

### Unit Tests (To Be Implemented)

- Document serialization/deserialization
- Stitch generation algorithms
- Tool behavior
- State mutations

### UI Tests (To Be Implemented)

- Tool selection
- Layer operations
- Canvas interactions
- Menu commands

### Integration Tests (To Be Implemented)

- File import/export
- Undo/redo
- Multi-layer operations

## Code Style Guide

### SwiftUI Best Practices

1. **Extract subviews** when body gets complex
2. **Use @ViewBuilder** for conditional views
3. **Prefer composition** over inheritance
4. **Keep views focused** on presentation

### State Management

1. **@State** for local view state
2. **@ObservedObject** for shared state
3. **@StateObject** for owned ObservableObjects
4. **@Binding** for two-way data flow

### Error Handling

1. Use `Result<Success, Failure>` for operations that can fail
2. Throw errors for exceptional cases
3. Provide user-friendly error messages

## Accessibility

### Current Implementation

- Native macOS controls (inherent accessibility)
- SF Symbols (system icons with built-in accessibility)
- Keyboard shortcuts for all major actions

### Future Improvements

- VoiceOver support for canvas elements
- High contrast mode support
- Keyboard-only navigation
- Accessibility labels for custom controls

## Localization

### Structure (Ready for Implementation)

- Use `NSLocalizedString` for all user-facing text
- Separate strings into `.strings` files
- Support for right-to-left languages
- Number/date formatting

## Security

### Current Measures

- **App Sandbox:** Enabled in entitlements
- **Hardened Runtime:** Enabled
- **File Access:** Limited to user-selected files

### Future Considerations

- Code signing
- Notarization for distribution
- Secure handling of imported files

## Build Configuration

### XcodeGen Benefits

1. **Version Control:** No merge conflicts in project file
2. **Reproducible:** Same configuration across team
3. **Maintainable:** YAML is human-readable
4. **Flexible:** Easy to add build configurations

### Build Settings

- **Debug:** Full optimization disabled, debug symbols
- **Release:** Full optimization, stripped symbols
- **Deployment Target:** macOS 13.0+

## Dependencies

### Current

All Apple frameworks:
- SwiftUI (UI framework)
- AppKit (macOS integration)
- Metal (GPU acceleration)
- MetalKit (Metal utilities)
- UniformTypeIdentifiers (File types)

### Future Considerations

- Image processing library for auto-digitize
- Vector graphics library
- Analytics (optional)

## Maintenance

### Code Health

- Keep files under 300 lines
- Extract complex logic into separate files
- Document all public APIs
- Remove unused code regularly

### Versioning

- Follow semantic versioning (MAJOR.MINOR.PATCH)
- Update `MARKETING_VERSION` in project.yml
- Tag releases in git

## Resources

### Apple Documentation

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [AppKit Documentation](https://developer.apple.com/documentation/appkit)
- [Metal Documentation](https://developer.apple.com/documentation/metal)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)

### Design References

- Pixelmator Pro (UI/UX inspiration)
- Photoshop (Tool organization)
- Hatch Embroidery (Feature set)
