//
//  Evaluations.swift
//  ObjectDetectionEvaluator
//
//  Created by Louis Lac on 07/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

extension Dictionary where Value == Evaluation {
    var mAP: Double {
        let mAP = self.reduce(0.0, { (accumulator, evaluation) -> Double in
            return accumulator + evaluation.value.mAP
        }) / Double(self.count)
        
        return mAP
    }
    
    var totalPositive: Int {
        return self.reduce(0, { (accumulator, evaluation) -> Int in
            return accumulator + evaluation.value.totalPositive
        })
    }
    
    // Not sure about this shit...
    var detections: [DetectionResult] {
        let allDetections = self.reduce(into: [DetectionResult]()) { (result, evaluation) in
            result += evaluation.value.detections
        }
        return allDetections.sorted(by: { (det1, det2) -> Bool in
            det1.recall > det2.recall
        })
    }
}
