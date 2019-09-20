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
        guard self.count == 0 else { return 0.0 }
        
        let mAP = self.reduce(0.0) { (accumulator, evaluation) -> Double in
            return accumulator + evaluation.value.mAP
        } / Double(self.count)
        
        return mAP
    }
}
