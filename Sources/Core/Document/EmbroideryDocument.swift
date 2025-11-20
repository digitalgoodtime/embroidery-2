//
//  EmbroideryDocument.swift
//  EmbroideryStudio
//
//  Core document model for embroidery designs
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Document Type

extension UTType {
    static let embroideryDesign = UTType(exportedAs: "com.embroidery.design")
}

// MARK: - Embroidery Document

struct EmbroideryDocument: FileDocument, Equatable {
    // MARK: - Properties

    var canvas: EmbroideryCanvas
    var layers: [EmbroideryLayer]
    var metadata: DocumentMetadata

    // MARK: - File Document Conformance

    static var readableContentTypes: [UTType] { [.embroideryDesign] }

    init() {
        self.canvas = EmbroideryCanvas()
        self.layers = []
        self.metadata = DocumentMetadata()
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(EmbroideryDocumentData.self, from: data)

        self.canvas = decoded.canvas
        self.layers = decoded.layers
        self.metadata = decoded.metadata
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = EmbroideryDocumentData(
            canvas: canvas,
            layers: layers,
            metadata: metadata
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let encoded = try encoder.encode(data)

        return FileWrapper(regularFileWithContents: encoded)
    }
}

// MARK: - Document Data

struct EmbroideryDocumentData: Codable {
    var canvas: EmbroideryCanvas
    var layers: [EmbroideryLayer]
    var metadata: DocumentMetadata
}

// MARK: - Embroidery Canvas

struct EmbroideryCanvas: Codable, Equatable {
    var width: Double = 800.0
    var height: Double = 600.0
    var backgroundColor: CodableColor = CodableColor(.white)
    var gridEnabled: Bool = true
    var gridSize: Double = 10.0
    var hoopSize: HoopSize = .standard4x4

    enum HoopSize: String, Codable, CaseIterable {
        case standard4x4 = "4x4"
        case large5x7 = "5x7"
        case extraLarge6x10 = "6x10"
        case jumbo8x12 = "8x12"

        var dimensions: (width: Double, height: Double) {
            switch self {
            case .standard4x4: return (100, 100)
            case .large5x7: return (127, 178)
            case .extraLarge6x10: return (152, 254)
            case .jumbo8x12: return (203, 305)
            }
        }
    }
}

// MARK: - Embroidery Layer

struct EmbroideryLayer: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var isVisible: Bool = true
    var isLocked: Bool = false
    var opacity: Double = 1.0
    var stitches: [StitchGroup] = []
}

// MARK: - Stitch Group

struct StitchGroup: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var type: StitchType
    var points: [StitchPoint] = []
    var color: CodableColor
    var density: Double = 4.0 // stitches per mm
}

enum StitchType: String, Codable {
    case running
    case satin
    case fill
    case applique
}

struct StitchPoint: Codable, Equatable {
    var x: Double
    var y: Double
}

// MARK: - Document Metadata

struct DocumentMetadata: Codable, Equatable {
    var createdDate: Date = Date()
    var modifiedDate: Date = Date()
    var author: String = ""
    var version: String = "1.0"
    var stitchCount: Int = 0
    var colorCount: Int = 0
}

// MARK: - Codable Color

struct CodableColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double

    init(_ color: NSColor) {
        // Convert to RGB color space if needed
        guard let rgbColor = color.usingColorSpace(.deviceRGB) else {
            // Fallback to white if conversion fails
            self.red = 1.0
            self.green = 1.0
            self.blue = 1.0
            self.alpha = 1.0
            return
        }

        self.red = Double(rgbColor.redComponent)
        self.green = Double(rgbColor.greenComponent)
        self.blue = Double(rgbColor.blueComponent)
        self.alpha = Double(rgbColor.alphaComponent)
    }

    var nsColor: NSColor {
        NSColor(deviceRed: red, green: green, blue: blue, alpha: alpha)
    }
}
