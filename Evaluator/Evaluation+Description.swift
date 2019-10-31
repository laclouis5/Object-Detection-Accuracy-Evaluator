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
        description += mAP.percent() + "\n"
        // The Following formatting could be improved with new StringRepresentable protocols
        description += "  Total Positive: \(nbGtPositive.decimal())\n"
        description += "  True Positive:  \(nbTP.decimal())\n"
        description += "  False Positive: \(nbFP.decimal())\n"
        
        return description
    }
}
