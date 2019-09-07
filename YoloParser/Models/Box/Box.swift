//
//  Box.swift
//  YoloParser
//
//  Created by Louis Lac on 15/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

struct Box: Hashable {
    // MARK: - Properties
    let name: String
    let x, y, w, h: Double
    let label: String
    let imgSize: Size?
    let confidence: Double?
    let coordType: CoordType
    let coordSystem: CoordinateSystem
    var detectionMode: DetectionMode {
        if confidence != nil {
            return .detection
        } else {
            return .groundTruth
        }
    }
    
    // MARK: - Initalizers
    init(name: String, a: Double, b: Double, c: Double, d: Double, label: String, coordType: CoordType = .XYWH, coordSystem: CoordinateSystem = .absolute, confidence: Double? = nil, imgSize: Size? = nil) {
        self.name = name
        self.label = label
        self.coordType = coordType
        self.coordSystem = coordSystem
        self.imgSize = imgSize
        self.confidence = confidence
        
        switch coordType {
        case .XYWH:
            (x, y, w, h) = (a, b, c, d)
        case .XYX2Y2:
            (x, y, w, h) = Box.convertToXYWH(xMin: a, yMin: b, xMax: c, yMax: d)
        }
    }
    
    init(name: String, rect: CGRect, label: String, coordSystem: CoordinateSystem = .absolute, confidence: Double? = nil, imgSize: Size? = nil) {
        let (x, y, w, h) = (Double(rect.midX), Double(rect.midY), Double(rect.width), Double(rect.height))
        self.init(name: name, a: x, b: y, c: w, d: h, label: label, coordType: .XYWH, coordSystem: coordSystem, confidence: confidence, imgSize: imgSize)
    }
    
    // MARK: - Methods
    // FIXME: Obsolete, change it
    func getRawBoundingBox(coordType: CoordType = .XYWH, coordSystem: CoordinateSystem = .absolute, imgSize: Size? = nil) -> (Double, Double, Double, Double)? {
        var a, b, c, d: Double
        
        switch coordType {
        case .XYWH:
            (a, b, c, d) = (x, y, w, h)
        case .XYX2Y2:
            (a, b, c, d) = Box.convertToXYX2Y2(x: x, y: y, w: w, h: h)
        }
        
        switch coordSystem {
        case .relative:
            guard let size = (imgSize ?? self.imgSize) else {
                print("Error: must provide img size when relative")
                return nil
            }
            (a, b, c, d) = Box.convertToRelative(a: x, b: y, c: w, d: h, imgSize: size)
        default:
            break
        }
        
        return (a, b, c, d)
    }
    
    func computeIoU(with box: Box) -> Double {
        //FIXME: change Box structure to accept all kinds of boxes (XYWH, XYX2Y2) and only compute XYX2Y2 when needed. do not necesarily systematically convert to XYWH
//        var (xMin1, yMin1, xMax1, yMax1): (Double, Double, Double, Double)
//        var (xMin2, yMin2, xMax2, yMax2): (Double, Double, Double, Double)
//        
//        switch (self.detectionMode, box.detectionMode) {
//        case let (mode1, mode2) where mode1 != mode2:
//
//        default:
//            break
//        }
//
        let (xMin1, yMin1, xMax1, yMax1) = Box.convertToXYX2Y2(x: x, y: y, w: w, h: h)
        let (xMin2, yMin2, xMax2, yMax2) = Box.convertToXYX2Y2(x: box.x, y: box.y, w: box.w, h: box.h)
        
        let (xA, yA, xB, yB) = (max(xMin1, xMin2), max(yMin1, yMin2), min(xMax1, xMax2), min(yMax1, yMax2))
        
        let intersection = (xB - xA)*(yB - yA)
        
        if intersection > 0.0 {
            let union = (xMax1 - xMin1)*(yMax1 - yMin1) + (xMax2 - xMin2)*(yMax2 - yMin2) - intersection
            return intersection / (union + Double.leastNonzeroMagnitude)
        } else {
            return 0.0
        }
    }
}

extension Box {
    static private func convertToXYX2Y2(x: Double, y: Double, w: Double, h: Double) -> (xMin: Double, yMin: Double, xMax: Double, yMax: Double) {
        return (x - w/2.0, y - h/2.0, x + w/2.0, y + h/2.0)
    }
    
    static private func convertToXYWH(xMin: Double, yMin: Double, xMax: Double, yMax: Double) -> (x: Double, y: Double, w: Double, h: Double) {
        let w = xMax - xMin
        let h = yMax - yMin
        return (xMin + w/2.0, yMin + h/2.0, w, h)
    }
    
    static private func convertToRelative(a: Double, b: Double, c: Double, d: Double, imgSize: Size) -> (Double, Double, Double, Double) {
        return (a/Double(imgSize.width), b/Double(imgSize.height), c/Double(imgSize.width), d/Double(imgSize.height))
    }
    
    static private func convertToAbsolute(a: Double, b: Double, c: Double, d: Double, imgSize: Size) -> (Double, Double, Double, Double) {
        return (a*Double(imgSize.width), b*Double(imgSize.height), c*Double(imgSize.width), d*Double(imgSize.height))
    }
}
