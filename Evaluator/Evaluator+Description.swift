//
//  EvaluatorExtensions.swift
//  ObjectDetectionEvaluator
//
//  Created by Louis Lac on 17/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

extension Evaluator: CustomStringConvertible {
    var description: String {
        var description = ""
        
        for label in evaluations.keys.sorted() {
            description += "\(label.uppercased())\n"
            description += evaluations[label]!.description + "\n"
        }
        return description
    }
}
