//
//  YoloParser.swift
//  YoloParser
//
//  Created by Louis Lac on 15/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

struct Parser {
    // MARK: - Methods
    /// Parses a txt file that represents the bounding boxes associated to an image, either detection or ground truth. Returns a BoundingBox array. Each line of the text file must represent a unique box with a label and an optional confidence.
    /// - Parameter fileURL: Absolute path to the txt file.
    /// - Parameter coordType: The reference coordinates used to describe rectangular boxes.
    /// - Parameter coordSystem: The coordinate system (absolute or relative) fro bounding boxes.
    static func parseFile(
        _ fileURL: URL,
        coordType: CoordType = .XYWH,
        coordSystem: CoordinateSystem = .relative
    ) throws -> BoundingBoxes {
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            throw ParserError.unreadableAnnotation(fileURL)
        }
        
        let lines = content.components(separatedBy: .newlines).filter {
            !$0.isEmpty
        }
        
        let boxes = try lines.map { rawLine -> BoundingBox in
            let line = rawLine.components(separatedBy: .whitespaces).filter {
                !$0.isEmpty
            }
            
            let label = String(line[0])
            
            // Case Ground Truth
            switch line.count {
            case 5:
                guard
                    let a = Double(line[1]),
                    let b = Double(line[2]),
                    let c = Double(line[3]),
                    let d = Double(line[4])
                else {
                    throw ParserError.invalidLineFormat(file: fileURL, line: rawLine)
                }
                
                let rect: CGRect
                switch coordType {
                case .XYWH:
                    rect = CGRect(midX: a, midY: b, width: c, height: d)
                case .XYX2Y2:
                    rect = CGRect(minX: a, minY: b, maxX: c, maxY: d)
                }
                
                return BoundingBox(
                    name: fileURL.lastPathComponent,
                    label: label,
                    box: rect,
                    coordSystem: coordSystem
                )
                
            // Case Detection
            case 6:
                guard
                    let confidence = Double(line[1]),
                    let a = Double(line[2]),
                    let b = Double(line[3]),
                    let c = Double(line[4]),
                    let d = Double(line[5])
                else {
                    throw ParserError.invalidLineFormat(file: fileURL, line: rawLine)
                }
                
                let rect: CGRect
                switch coordType {
                case .XYWH:
                    rect = CGRect(midX: a, midY: b, width: c, height: d)
                case .XYX2Y2:
                    rect = CGRect(minX: a, minY: b, maxX: c, maxY: d)
                }
                
                return BoundingBox(
                    name: fileURL.lastPathComponent,
                    label: label,
                    box: rect,
                    coordSystem: coordSystem,
                    confidence: confidence
                )
            // Case wrong annotation
            default:
                throw ParserError.invalidLineFormat(file: fileURL, line: rawLine)
            }
        }
        
        return boxes
    }
    
    /// Parses an entire folder containing txt files each representing the detections associated with one image. Returns an array of BoundingBox objects.
    /// - Parameter folder: Absolute path to the folder.
    /// - Parameter coordType: The reference coordinates used to describe rectangular boxes.
    /// - Parameter coordSystem: The coordinate system (absolute or relative) fro bounding boxes.
    static func parseFolder(
        _ folder: URL,
        coordType: CoordType = .XYWH,
        coordSystem: CoordinateSystem = .relative
    ) throws -> BoundingBoxes {
        let fileManager = FileManager.default
        
        guard var files = try? fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
        else {
            throw ParserError.folderNotListable(folder)
        }
        
        files = files.filter { $0.pathExtension == "txt" }
        
        return try files.flatMap { url in
            try parseFile(
                url,
                coordType: coordType,
                coordSystem: coordSystem
            )
        }
    }
}
