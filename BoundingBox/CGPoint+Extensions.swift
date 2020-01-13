//
//  CGPoint+Extensions.swift
//  ObjectDetectionEvaluator
//
//  Created by Louis Lac on 08/01/2020.
//  Copyright © 2020 Louis Lac. All rights reserved.
//

import Foundation

extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        let dx = self.x - other.x
        let dy = self.y - other.y
        
        return hypot(dx, dy)
    }
}
