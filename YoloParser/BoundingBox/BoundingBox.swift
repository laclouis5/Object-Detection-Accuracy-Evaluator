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
    let name: String
    let box: CGRect
    let label: String
    let imgSize: CGSize?
    let confidence: Double?
    let coordSystem: CoordinateSystem
    var detectionMode: DetectionMode {
        if confidence != nil {
            return .detection
        } else {
            return .groundTruth
        }
    }
    
    // MARK: - Initalizers
    init(name: String, box: CGRect, label: String, coordSystem: CoordinateSystem = .absolute, confidence: Double? = nil, imgSize: CGSize? = nil) {
        self.name = name
        self.box = box
        self.label = label
        self.imgSize = imgSize
        self.confidence = confidence
        self.coordSystem = coordSystem
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