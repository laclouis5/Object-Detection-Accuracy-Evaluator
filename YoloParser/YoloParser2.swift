//
//  YoloParser2.swift
//  ObjectDetectionEvaluator
//
//  Created by Louis Lac on 05/10/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

struct Parser2 {
    struct Line {
        var label: String
        var x, y, w, h: Double
        var confidence: Double?
    }
    
    static func parseFolder(
        _ url: URL,
        coordType: CoordType = .XYWH,
        coordSystem: CoordinateSystem = .relative
    ) throws -> [BoundingBox] {
        let fileManager = FileManager.default
        
        guard let files = try? fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil
        ) else {
            throw Error.folderNotListable(url)
        }
        
        let txtFiles = files.filter { $0.pathExtension == "txt" }

        do {
            let boxes = try txtFiles.flatMap {
                try parseFile($0, coordType: coordType, coordSystem: coordSystem)
            }
            return boxes
        } catch {
            throw error
        }
    }
    
    static func parseFile(
        _ url: URL,
        coordType: CoordType = .XYWH,
        coordSystem: CoordinateSystem = .relative
    ) throws -> [BoundingBox] {
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            throw Error.unreadableAnnotation(url)
        }
        
        var boxes = [BoundingBox]()
        
        let fileScanner = Scanner(string: content)
        let newLine = CharacterSet(charactersIn: "\n")
        fileScanner.charactersToBeSkipped = newLine
        
        while !fileScanner.isAtEnd {
            guard let string = fileScanner .scanUpToCharacters(from: newLine) else {
                throw Error.unreadableAnnotation(url)
            }
            
            guard let line = parseLine(string) else {
                throw Error.invalidLineFormat(file: url, line: string)
            }
            
            var box: CGRect
            switch coordType {
            case .XYWH:
                box = CGRect(midX: line.x, midY: line.y, width: line.w, height: line.h)
            default:
                box = CGRect(minX: line.x, minY: line.y, maxX: line.w, maxY: line.h)
            }
            
            boxes.append(BoundingBox(
                name: url.absoluteString,
                label: line.label,
                box: box,
                coordSystem: coordSystem,
                confidence: line.confidence,
                imgSize: nil
            ))
        }
        
        return boxes
    }
    
    private static func parseLine(_ string: String) -> Line? {
        let scanner = Scanner(string: string)
        let whiteSpace = CharacterSet(charactersIn: " ")
        scanner.charactersToBeSkipped = whiteSpace
        
        guard
            let a = scanner.scanUpToCharacters(from: whiteSpace),
            let b = scanner.scanDouble(),
            let c = scanner.scanDouble(),
            let d = scanner.scanDouble(),
            let e = scanner.scanDouble()
        else {
            return nil
        }
        
        if let f = scanner.scanDouble() {
            return Line(label: a, x: c, y: d, w: e, h: f, confidence: b)
        } else {
            return Line(label: a, x: b, y: c, w: d, h: e, confidence: nil)
        }
    }
}

fileprivate extension Scanner {
    func scanUpToCharacters(from set: CharacterSet) -> String? {
        var result: NSString?
        return scanUpToCharacters(from: set, into: &result) ? (result as String?) : nil
    }
    
    func scanUpTo(_ string: String) -> String? {
        var result: NSString?
        return self.scanUpTo(string, into: &result) ? (result as String?) : nil
    }
    
    func scanDouble() -> Double? {
        var double = 0.0
        return scanDouble(&double) ? double : nil
    }
    
    func scanInt() -> Int? {
        var int = 0
        return scanInt(&int) ? int : nil
    }
}
