//
//  Evaluation.swift
//  YoloParser
//
//  Created by Louis Lac on 07/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

struct Evaluation {
    //MARK: - Properties
    var nbGtPositive = 0
    var mAP = 0.0
    var truePositives = [Bool]()
    var confidences = [Double]()
    var precisions = [Double]()
    var recalls = [Double]()
    
    var nbDetections: Int {
        truePositives.count
    }
    var nbTP: Int {
        truePositives.count(where: { $0 == true })
    }
    
    var nbFP: Int {
        truePositives.count(where: { $0 == false })
    }
    
    // MARK: - Subscripts
    subscript(i: Int) -> (Bool, Double, Double, Double) {
        (truePositives[i], confidences[i], recalls[i], precisions[i])
    }
}
