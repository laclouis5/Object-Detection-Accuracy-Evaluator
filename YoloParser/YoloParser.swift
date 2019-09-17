//
//  YoloParser.swift
//  YoloParser
//
//  Created by Louis Lac on 15/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

struct Parser {
    func parseYoloTxtFile(_ fileURL: URL, coordType: CoordType = .XYX2Y2, coordSystem: CoordinateSystem = .absolute) throws -> [BoundingBox] {
//        var boxes = [BoundingBox]()
        
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            throw YoloParserError.unreadableAnnotation(fileURL)
        }
        
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        let boxes = try lines.map({ (rawLine) -> BoundingBox in
            let line  = rawLine.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            let label = String(line[0])
            
            // Case Ground Truth
            if line.count == 5 {
                guard let x = Double(line[1]), let y = Double(line[2]), let w = Double(line[3]), let h = Double(line[4]) else {
                    throw YoloParserError.invalidLineFormat(file: fileURL, line: rawLine)
                }
                
                let rect: CGRect
                switch coordType {
                case .XYWH:
                    rect = CGRect(midX: x, midY: y, width: w, height: h)
                case .XYX2Y2:
                    rect = CGRect(minX: x, minY: y, maxX: w, maxY: h)
                }
                
                return BoundingBox(name: fileURL.lastPathComponent, label: label, box: rect, coordSystem: coordSystem)
                
            // Case Detection
            } else if line.count == 6 {
                guard let confidence = Double(line[1]), let x = Double(line[2]), let y = Double(line[3]), let w = Double(line[4]), let h = Double(line[5]) else {
                    throw YoloParserError.invalidLineFormat(file: fileURL, line: rawLine)
                }
                
                let rect: CGRect
                switch coordType {
                case .XYWH:
                    rect = CGRect(midX: x, midY: y, width: w, height: h)
                case .XYX2Y2:
                    rect = CGRect(minX: x, minY: y, maxX: w, maxY: h)
                }
                
                return BoundingBox(name: fileURL.lastPathComponent, label: label, box: rect, coordSystem: coordSystem, confidence: confidence)
                
            } else {
                throw YoloParserError.invalidLineFormat(file: fileURL, line: rawLine)
            }
        })
        
        return boxes
    }

    func parseYoloFolder(_ folder: URL, coordType: CoordType = .XYX2Y2, coordSystem: CoordinateSystem = .absolute) throws -> [BoundingBox] {
        let fileManager = FileManager.default
        
        guard var files = try? fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) else {
            throw YoloParserError.folderNotListable(folder)
        }
        
        files = files.filter { $0.pathExtension == "txt" }
        
        return try files.flatMap { (url) -> [BoundingBox] in
            do {
                let boxes = try parseYoloTxtFile(url, coordType: coordType, coordSystem: coordSystem)
                return boxes
            } catch YoloParserError.unreadableAnnotation(let fileURL) {
                throw YoloParserError.unreadableAnnotation(fileURL)
            } catch YoloParserError.invalidLineFormat(let fileURL, let line) {
                throw YoloParserError.invalidLineFormat(file: fileURL, line: line)
            }
        }
    }
}
