//
//  BoxExtensions.swift
//  YoloParser
//
//  Created by Louis Lac on 07/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

extension BoundingBox: CustomStringConvertible {
    var description: String {
        var description = "\(self.label):"
        
        description += " (x: \(self.box.midX), y: \(self.box.midY), width: \(self.box.width), height: \(self.box.height))"
        
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
