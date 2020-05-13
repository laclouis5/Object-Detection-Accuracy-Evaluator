//
//  Evaluations.swift
//  ObjectDetectionEvaluator
//
//  Created by Louis Lac on 07/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

typealias Evaluations = Dictionary<String, Evaluation>

extension Dictionary where Value == Evaluation {
    // FIXME: could be improve to take less memory (use reduce, no map)
    // Should be a func as it is O(n)
    var mAP: Double {
        mean(for: \.value.mAP)
    }
}
