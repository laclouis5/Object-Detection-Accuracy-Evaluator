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
    var confidence: Double? = nil
    var imgSize: CGSize? = nil
    
    var detectionMode: DetectionMode {
        if confidence == nil {
            return .groundTruth
        } else {
            return .detection
        }
    }
    
    // MARK: - Methods
    /// Returns the Intersection over Union of two bounding boxes.
    func iou(with bbox: BoundingBox) -> Double {
        Double(box.iou(with: bbox.box))
    }
    
    /// Returns the distance between the center of two boxes.
    func distance(to bbox: BoundingBox) -> Double {
        Double(box.distance(to: bbox.box))
    }
    
    /// Returns the 4 coordinates describing the bounding box as a CGRect.
    /// - Parameter imgSize: Image size in pixels.
    func absoluteBox(relativeTo imgSize: CGSize? = nil) -> CGRect? {
        if imgSize == nil && self.imgSize == nil {
            return nil
        }
        
        if let imgSize = imgSize {
            return box.absoluteBox(relativeTo: imgSize)
        }
        else if let imgSize = self.imgSize {
            return box.absoluteBox(relativeTo: imgSize)
        }
        else { return nil }
    }
}
