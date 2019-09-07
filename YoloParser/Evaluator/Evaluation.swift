//
//  Evaluation.swift
//  YoloParser
//
//  Created by Louis Lac on 07/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

struct Evaluation {
    var label = ""
    var mAP = 0.0
    var truePositives = [Bool]()
    var totalPositive = 0
    var precisions = [Double]()
    var recalls = [Double]()
    
    // MARK: - Initializers
    init() { }
    
    init(label: String) {
        self.label = label
    }
    
    // Reserve capacity to avoid copy overhead with large collections
    init(for label: String, reservingCapacity capacity: Int) {
        self.init(label: label)
        
        truePositives.reserveCapacity(capacity)
        precisions.reserveCapacity(capacity)
        recalls.reserveCapacity(capacity)
    }
}

extension Evaluation: CustomStringConvertible {
    var description: String {
        var description = "\(label.uppercased())\n"
        description += "  Total Positive: \(totalPositive)\n"
        description += "  True Positive:  \(truePositives.filter { $0 }.count)\n"
        description += "  False Positive: \(truePositives.count - truePositives.filter { $0 }.count)\n"
        return description
    }
}
