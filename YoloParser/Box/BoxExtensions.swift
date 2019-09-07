//
//  BoxExtensions.swift
//  YoloParser
//
//  Created by Louis Lac on 07/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

extension Box: CustomStringConvertible {
    var description: String {
        var description = "\(self.label):"
        switch self.coordType {
        case .XYX2Y2:
            description += " (xMin: \(self.x), yMin: \(self.y), xMax: \(self.w), yMax: \(self.h))"
        default:
            description += " (x: \(self.x), y: \(self.y), w: \(self.w), h: \(self.h))"
        }
        
        switch self.coordSystem {
        case .absolute:
            description += " abs. coords"
        default:
            description += " rel. coords"
        }
        
        switch self.detectionMode {
        case .groundTruth:
            description += ", ground truth"
        case .detection:
            description += ", detection with confidence \(confidence!)"
        }
        
        return description
    }
}
