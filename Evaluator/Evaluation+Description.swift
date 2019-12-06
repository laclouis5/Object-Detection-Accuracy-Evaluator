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
        var description = "\(mAP, style: .percent)\n"
        description += "  Total Positive: \(nbGtPositive, style: .decimal)\n"
        description += "  True Positive:  \(nbTP, style: .decimal)\n"
        description += "  False Positive: \(nbFP, style: .decimal)\n"
        
        return description
    }
}
