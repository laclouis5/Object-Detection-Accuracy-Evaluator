//
//  CGRectExtensions.swift
//  ObjectDetectionEvaluator
//
//  Created by Louis Lac on 09/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

extension CGRect {
    // MARK: - Properties
    var center: CGPoint {
        get {
            CGPoint(x: self.midX, y: self.midY)
        } set {
            let newX = newValue.x - self.width / 2.0
            let newY = newValue.y - self.height / 2.0
            
            origin = CGPoint(x: newX, y: newY)
        }
    }
    
    var area: CGFloat {
        self.width * self.height
    }
    
    // MARK: - Initializers
    init(midX: CGFloat, midY: CGFloat, width: CGFloat, height: CGFloat) {
        let minX = midX - width / 2.0
        let minY = midY - height / 2.0
        
        self.init(x: minX, y: minY, width: width, height: height)
    }
    
    init(midX: Double, midY: Double, width: Double, height: Double) {
        self.init(midX: CGFloat(midX), midY: CGFloat(midY), width: CGFloat(width), height: CGFloat(height))
    }
    
    init(midX: Int, midY: Int, width: Int, height: Int) {
        self.init(midX: CGFloat(midX), midY: CGFloat(midY), width: CGFloat(width), height: CGFloat(height))
    }
    
    init(minX: CGFloat, minY: CGFloat, maxX: CGFloat, maxY: CGFloat) {
        let width  = maxX - minX
        let height = maxY - minY
        
        self.init(x: minX, y: minY, width: width, height: height)
    }
    
    init(minX: Double, minY: Double, maxX: Double, maxY: Double) {
        self.init(minX: CGFloat(minX), minY: CGFloat(minY), maxX: CGFloat(maxX), maxY: CGFloat(maxY))
    }
    
    init(minX: Int, minY: Int, maxX: Int, maxY: Int) {
        self.init(minX: CGFloat(minX), minY: CGFloat(minY), maxX: CGFloat(maxX), maxY: CGFloat(maxY))
    }
    
    // MARK: - Methods
    /// Returns the Intersection over Union of two CGrect.
    func iou(with rect: CGRect) -> CGFloat {
        guard intersects(rect) else {
            return 0.0
        }
        
        let intersection = self.intersection(rect).area
        let union = self.area + rect.area - intersection
        
        return intersection / (union + CGFloat.leastNonzeroMagnitude)
    }
    
    /// Returns the distance between the center of two CGrect.
    func distance(with rect: CGRect) -> CGFloat {
        let dx = self.midX - rect.midX
        let dy = self.midY - rect.midY
        
        return sqrt(dx*dx + dy*dy)
    }
    
    /// Returns the 4 coordinates describing the bounding box as a CGRect.
    /// - Parameter imgSize: Image size in pixels.
    func absoluteBox(relativeTo imgSize: CGSize) -> CGRect {
        let x = midX / imgSize.width
        let y = midY / imgSize.height
        let w = width / imgSize.width
        let h = height / imgSize.height
        
        return CGRect(midX: x, midY: y, width: w, height: h)
    }
}
