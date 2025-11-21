import Foundation
import CoreText
import AppKit

/// Generates vector paths from text strings for embroidery stitch conversion
class TextPathGenerator {

    /// Result of path generation containing paths and metadata
    struct PathResult {
        let glyphPaths: [GlyphPath]
        let bounds: CGRect
        let baselineY: CGFloat

        struct GlyphPath {
            let path: CGPath
            let bounds: CGRect
            let character: Character
        }
    }

    /// Generate paths for text with given font and layout properties
    /// - Parameters:
    ///   - text: The text string to convert
    ///   - font: NSFont to use
    ///   - position: Starting position (bottom-left of first character)
    ///   - letterSpacing: Additional spacing between characters in points
    ///   - alignment: Text alignment
    /// - Returns: PathResult containing all glyph paths and metadata
    func generatePaths(
        for text: String,
        font: NSFont,
        at position: CGPoint,
        letterSpacing: CGFloat = 0,
        alignment: TextObject.TextAlignment = .left
    ) -> PathResult {
        // Create attributed string with font
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .kern: letterSpacing // NSAttributedString handles letter spacing
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)

        // Create CTLine for layout
        let line = CTLineCreateWithAttributedString(attributedString)

        // Get glyph runs
        guard let runs = CTLineGetGlyphRuns(line) as? [CTRun], !runs.isEmpty else {
            return PathResult(glyphPaths: [], bounds: .zero, baselineY: 0)
        }

        // Calculate total line width for alignment
        let lineWidth = CTLineGetTypographicBounds(line, nil, nil, nil)

        // Adjust starting position based on alignment
        var currentX = position.x
        switch alignment {
        case .center:
            currentX -= lineWidth / 2
        case .right:
            currentX -= lineWidth
        case .left:
            break
        }

        // Capture Y position (will be shadowed by local variable in loop)
        let baseY = position.y
        print("DEBUG TextPathGenerator: User clicked at position.y = \(position.y), baseY = \(baseY)")

        var glyphPaths: [PathResult.GlyphPath] = []
        var overallBounds: CGRect = .zero

        // Process each run
        for run in runs {
            let glyphCount = CTRunGetGlyphCount(run)

            // Get glyphs and positions
            var glyphs = [CGGlyph](repeating: 0, count: glyphCount)
            var positions = [CGPoint](repeating: .zero, count: glyphCount)

            CTRunGetGlyphs(run, CFRangeMake(0, glyphCount), &glyphs)
            CTRunGetPositions(run, CFRangeMake(0, glyphCount), &positions)

            // Get the font for this run
            let runAttributes = CTRunGetAttributes(run) as? [NSAttributedString.Key: Any]
            let runFont = runAttributes?[.font] as? NSFont ?? font

            // Get character indices
            var indices = [CFIndex](repeating: 0, count: glyphCount)
            CTRunGetStringIndices(run, CFRangeMake(0, glyphCount), &indices)

            // Convert each glyph to a path
            for i in 0..<glyphCount {
                let glyph = glyphs[i]
                let position = positions[i]

                // Get character
                let stringIndex = String.Index(utf16Offset: indices[i], in: text)
                let character = text[stringIndex]

                // Create path for glyph
                if let glyphPath = CTFontCreatePathForGlyph(runFont, glyph, nil) {
                    // Create mutable copy to apply transform
                    let mutablePath = CGMutablePath()

                    // CoreText uses bottom-left origin (Y increases upward)
                    // Canvas uses top-left origin (Y increases downward)
                    // Need to flip Y-axis and apply translation
                    // After scaleY: -1, translatedBy operates in flipped space, so negate Y
                    var transform = CGAffineTransform(scaleX: 1, y: -1)
                    transform = transform.translatedBy(
                        x: currentX + position.x,
                        y: -baseY
                    )
                    mutablePath.addPath(glyphPath, transform: transform)

                    // Get bounds for this glyph
                    let glyphBounds = mutablePath.boundingBoxOfPath

                    let glyphPathResult = PathResult.GlyphPath(
                        path: mutablePath,
                        bounds: glyphBounds,
                        character: character
                    )

                    glyphPaths.append(glyphPathResult)

                    // Update overall bounds
                    if overallBounds == .zero {
                        overallBounds = glyphBounds
                    } else {
                        overallBounds = overallBounds.union(glyphBounds)
                    }
                }
            }
        }

        // Calculate baseline (most glyphs sit on this line)
        let baselineY = position.y

        return PathResult(
            glyphPaths: glyphPaths,
            bounds: overallBounds,
            baselineY: baselineY
        )
    }

    /// Convert font size from mm to points (for NSFont creation)
    /// Embroidery uses mm, but NSFont uses points
    /// At 72 DPI: 1 inch = 72 points = 25.4 mm
    /// So: 1 mm ≈ 2.83465 points
    static func mmToPoints(_ mm: Double) -> CGFloat {
        return CGFloat(mm * 2.83465)
    }

    /// Convert font size from points to mm (for display)
    static func pointsToMM(_ points: CGFloat) -> Double {
        return Double(points / 2.83465)
    }

    /// Sample points along a path at regular intervals, splitting by subpath
    /// Used for converting paths to stitch points
    /// - Parameters:
    ///   - path: The CGPath to sample
    ///   - density: Stitch density in stitches per mm
    /// - Returns: Array of subpath point arrays
    func samplePathBySubpath(_ path: CGPath, density: Double) -> [[CGPoint]] {
        var allSubpaths: [[CGPoint]] = []
        var currentSubpath: [CGPoint] = []

        // Calculate sampling interval based on density
        // Higher density = smaller interval
        let interval = 1.0 / density // mm between samples

        var previousPoint: CGPoint?
        var subpathStart: CGPoint?  // Track start of current subpath

        path.applyWithBlock { element in
            let elementType = element.pointee.type
            let elementPoints = element.pointee.points

            switch elementType {
            case .moveToPoint:
                // Save previous subpath if it exists
                if !currentSubpath.isEmpty {
                    allSubpaths.append(currentSubpath)
                    currentSubpath = []
                }

                let point = elementPoints[0]
                currentSubpath.append(point)
                previousPoint = point
                subpathStart = point  // Mark start of new subpath

            case .addLineToPoint:
                let point = elementPoints[0]
                if let previous = previousPoint {
                    // Add intermediate points along line
                    let dx = point.x - previous.x
                    let dy = point.y - previous.y
                    let length = sqrt(dx * dx + dy * dy)

                    let numSegments = max(1, Int(ceil(length / interval)))

                    for i in 1...numSegments {
                        let t = CGFloat(i) / CGFloat(numSegments)
                        let interpolated = CGPoint(
                            x: previous.x + dx * t,
                            y: previous.y + dy * t
                        )
                        currentSubpath.append(interpolated)
                    }
                }
                previousPoint = point

            case .addQuadCurveToPoint:
                let control = elementPoints[0]
                let end = elementPoints[1]
                if let start = previousPoint {
                    // Sample quadratic bezier curve
                    let curvePoints = sampleQuadraticBezier(
                        start: start,
                        control: control,
                        end: end,
                        interval: interval
                    )
                    currentSubpath.append(contentsOf: curvePoints)
                }
                previousPoint = end

            case .addCurveToPoint:
                let control1 = elementPoints[0]
                let control2 = elementPoints[1]
                let end = elementPoints[2]
                if let start = previousPoint {
                    // Sample cubic bezier curve
                    let curvePoints = sampleCubicBezier(
                        start: start,
                        control1: control1,
                        control2: control2,
                        end: end,
                        interval: interval
                    )
                    currentSubpath.append(contentsOf: curvePoints)
                }
                previousPoint = end

            case .closeSubpath:
                // Close the current subpath by connecting back to its start
                if let start = subpathStart, let last = previousPoint, start != last {
                    // Add intermediate points to close the gap smoothly
                    let dx = start.x - last.x
                    let dy = start.y - last.y
                    let length = sqrt(dx * dx + dy * dy)

                    let numSegments = max(1, Int(ceil(length / interval)))

                    for i in 1...numSegments {
                        let t = CGFloat(i) / CGFloat(numSegments)
                        let interpolated = CGPoint(
                            x: last.x + dx * t,
                            y: last.y + dy * t
                        )
                        currentSubpath.append(interpolated)
                    }
                }

            @unknown default:
                break
            }
        }

        // Add final subpath
        if !currentSubpath.isEmpty {
            allSubpaths.append(currentSubpath)
        }

        return allSubpaths
    }

    /// Sample points along a quadratic bezier curve
    private func sampleQuadraticBezier(
        start: CGPoint,
        control: CGPoint,
        end: CGPoint,
        interval: CGFloat
    ) -> [CGPoint] {
        // Approximate curve length
        let chordLength = distance(start, end)
        let controlLength = distance(start, control) + distance(control, end)
        let approximateLength = (chordLength + controlLength) / 2

        let numSamples = max(2, Int(ceil(approximateLength / interval)))
        var points: [CGPoint] = []

        for i in 1...numSamples {
            let t = CGFloat(i) / CGFloat(numSamples)
            let point = quadraticBezierPoint(t: t, p0: start, p1: control, p2: end)
            points.append(point)
        }

        return points
    }

    /// Sample points along a cubic bezier curve
    private func sampleCubicBezier(
        start: CGPoint,
        control1: CGPoint,
        control2: CGPoint,
        end: CGPoint,
        interval: CGFloat
    ) -> [CGPoint] {
        // Approximate curve length
        let chordLength = distance(start, end)
        let controlLength = distance(start, control1) + distance(control1, control2) + distance(control2, end)
        let approximateLength = (chordLength + controlLength) / 2

        let numSamples = max(2, Int(ceil(approximateLength / interval)))
        var points: [CGPoint] = []

        for i in 1...numSamples {
            let t = CGFloat(i) / CGFloat(numSamples)
            let point = cubicBezierPoint(t: t, p0: start, p1: control1, p2: control2, p3: end)
            points.append(point)
        }

        return points
    }

    /// Calculate point on quadratic bezier curve
    private func quadraticBezierPoint(t: CGFloat, p0: CGPoint, p1: CGPoint, p2: CGPoint) -> CGPoint {
        let oneMinusT = 1 - t
        let x = oneMinusT * oneMinusT * p0.x + 2 * oneMinusT * t * p1.x + t * t * p2.x
        let y = oneMinusT * oneMinusT * p0.y + 2 * oneMinusT * t * p1.y + t * t * p2.y
        return CGPoint(x: x, y: y)
    }

    /// Calculate point on cubic bezier curve
    private func cubicBezierPoint(t: CGFloat, p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGPoint {
        let oneMinusT = 1 - t
        let oneMinusT2 = oneMinusT * oneMinusT
        let oneMinusT3 = oneMinusT2 * oneMinusT
        let t2 = t * t
        let t3 = t2 * t

        let x = oneMinusT3 * p0.x + 3 * oneMinusT2 * t * p1.x + 3 * oneMinusT * t2 * p2.x + t3 * p3.x
        let y = oneMinusT3 * p0.y + 3 * oneMinusT2 * t * p1.y + 3 * oneMinusT * t2 * p2.y + t3 * p3.y

        return CGPoint(x: x, y: y)
    }

    /// Calculate distance between two points
    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        return sqrt(dx * dx + dy * dy)
    }
}
