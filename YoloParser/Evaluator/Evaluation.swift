//
//  Evaluation.swift
//  YoloParser
//
//  Created by Louis Lac on 07/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

struct Evaluation {
    var mAP = 0.0
    var totalPositive = 0
    var detections = [Detection]()
    
    init() { }
    
    // Reserve capacity to avoid copy overhead with large collections
    init(reservingCapacity capacity: Int) {
        detections.reserveCapacity(capacity)
    }
}

extension Evaluation: CustomStringConvertible {
    var description: String {
        var description = ""
        description += "mAP: \(mAP)\n"
        description += "  Total Positive: \(totalPositive)\n"
        description += "  True Positive:  \(detections.filter { $0.TP }.count)\n"
        description += "  False Positive: \(detections.count - detections.filter { $0.TP }.count)\n"
        
        return description
    }
}
