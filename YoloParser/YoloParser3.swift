//
//  YoloParser3.swift
//  ObjectDetectionEvaluator
//
//  Created by Louis Lac on 06/05/2020.
//  Copyright © 2020 Louis Lac. All rights reserved.
//

import Foundation

//struct Parser3 {
//    static func parseGtFile(url: URL, coordType: CoordType, coordSystem: CoordinateSystem) throws -> BoundingBoxes {
//        guard let content = try? String(contentsOf: url) else {
//            throw ParserError.unreadableAnnotation(url)
//        }
//        
//        let lines = content.split(separator: "\n")
//        
//        let boxes = try lines.map { (line) -> BoundingBox in
//            let label = String(lines[0])
//            
//            guard let x = Double(lines[1]),
//                let y = Double(lines[2]),
//                let w = Double(lines[3]),
//                let h = Double(lines[4])
//            else {
//                throw ParserError.invalidLineFormat(file: url, line: "")
//            }
//            
//            return BoundingBox(name: url.lastPathComponent, label: label, box: CGRect(midX: x, midY: y, width: w, height: h), coordSystem: .absolute)
//        }
//        
//        return boxes
//    }
//    
//    static func parseGtFolder(url: URL, coordType: CoordType, coordSystem: CoordinateSystem) throws -> BoundingBoxes {
//        let fileManager = FileManager.default
//        guard let files = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
//        
//    }
//}
