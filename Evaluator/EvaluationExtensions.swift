//
//  EvaluationExtensions.swift
//  ObjectDetectionEvaluator
//
//  Created by Louis Lac on 17/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

extension Evaluation: CustomStringConvertible {
    var description: String {
        var description = ""
        description += "mAP: \(Double(Int(10_000 * mAP)) / 100) %\n"
        description += "  Total Positive: \(nbGtPositive)\n"
        description += "  True Positive:  \(nbTP)\n"
        description += "  False Positive: \(nbFP)\n"
        
        return description
    }
}
