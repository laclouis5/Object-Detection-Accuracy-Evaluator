//
//  Evaluation.swift
//  YoloParser
//
//  Created by Louis Lac on 07/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

struct Evaluation {
    var nbGtPositive  = 0
    var mAP           = 0.0
    var truePositives = [Bool]()
    var precisions    = [Double]()
    var recalls       = [Double]()
    
    var nbDetections: Int {
        return truePositives.count
    }
    
    var nbTP: Int {
        return truePositives.filter { $0 }.count
    }
    
    var nbFP: Int {
        return truePositives.filter { !$0 }.count
    }
    
    subscript(i: Int) -> (Bool, Double, Double) {
        return (truePositives[i], recalls[i], precisions[i])
    }
}

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
