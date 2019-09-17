//
//  BoundingBox.swift
//  YoloParser
//
//  Created by Louis Lac on 15/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

struct BoundingBox {
    
    // MARK: - Properties
    var name: String
    var label: String
    var box: CGRect
    var coordSystem: CoordinateSystem
    var confidence: Double?
    var imgSize: CGSize?
    var detectionMode: DetectionMode {
        if confidence != nil {
            return .detection
        } else {
            return .groundTruth
        }
    }
    
    // Mark: - Initializers
    init(name: String, label: String, box: CGRect, coordSystem: CoordinateSystem, confidence: Double? = nil, imgSize: CGSize? = nil) {
        self.name = name
        self.label = label
        self.box = box
        self.coordSystem = coordSystem
        self.confidence = confidence
        self.imgSize = imgSize
    }
    
    // MARK: - Methods
    func iou(with bbox: BoundingBox) -> Double {
        return Double(box.iou(with: bbox.box))
    }
    
    func absoluteBox(relativeTo imgSize: CGSize? = nil) -> CGRect? {
        if imgSize == nil && self.imgSize == nil {
            return nil
        }
        if let imgSize = imgSize {
            return box.absoluteBox(relativeTo: imgSize)
        }
        else if let imgSize = self.imgSize {
            return box.absoluteBox(relativeTo: imgSize)
            
        } else { return nil }
    }
}
