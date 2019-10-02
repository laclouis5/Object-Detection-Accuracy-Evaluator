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
        reduce(0.0) { (accumulator, evaluation) -> Double in
            accumulator + evaluation.value.mAP
            } / (Double(count) + Double.leastNonzeroMagnitude)
    }
}
