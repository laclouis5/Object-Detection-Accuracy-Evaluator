//
//  Evaluation.swift
//  YoloParser
//
//  Created by Louis Lac on 07/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

struct Evaluation {
    var totalPositive = 0
    var detections    = [DetectionResult]()
    
    var precisions: [Double] {
        return detections.map{ $0.precision }
    }
    
    var recalls: [Double] {
        return detections.map{ $0.recall }
    }
    
    init() { }
    
    // Reserve capacity to avoid copy overhead with large collections
    init(reservingCapacity capacity: Int) {
        detections.reserveCapacity(capacity)
    }
    
    // Base on VOC 2012 Matlab code
    var mAP: Double {
        var mAP = 0.0
        
        var precs = [0.0] + precisions + [0.0]
        var recs  = [0.0] + recalls    + [1.0]
        
        for i in (0..<precs.count-1).reversed() {
            precs[i] = max(precs[i], precs[i+1])
        }
        
        var indexList = [Int]()
        
        for i in 1..<recs.count {
            if recs[i] != recs[i-1] {
                indexList.append(i)
            }
        }
        
        for i in indexList {
            mAP += (recs[i] - recs[i-1]) * precs[i]
        }
        
        return mAP
    }
}

extension Evaluation: CustomStringConvertible {
    var description: String {
        var description = ""
        description += "mAP: \(Double(Int(10_000 * mAP)) / 100) %\n"
        description += "  Total Positive: \(totalPositive)\n"
        description += "  True Positive:  \(detections.filter { $0.TP }.count)\n"
        description += "  False Positive: \(detections.count - detections.filter { $0.TP }.count)\n"
        
        return description
    }
}
