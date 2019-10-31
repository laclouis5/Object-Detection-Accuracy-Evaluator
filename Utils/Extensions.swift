//
//  Extensions.swift
//  ObjectDetectionEvaluator
//
//  Created by Louis Lac on 16/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

extension Array where Element == Bool {
    var cumSum: [Int] {
        reduce(into: [Int]()) { (cumSum, bool) in
            cumSum.append((cumSum.last ?? 0) + (bool ? 1 : 0))
        }
    }
}

extension Array where Element == Int {
    var cumSum: [Int] {
        reduce(into: [Int]()) { (cumSum, element) in
            cumSum.append((cumSum.last ?? 0) + element)
        }
    }
}

extension Array where Element == Double {
    var mean: Double {
        reduce(0.0, +) / Double(count)
    }
}

extension Dictionary where Value == [BoundingBox] {
    var nbBoundingBoxes: Int {
        reduce(0) { (nbBBoxes, element) -> Int in
            nbBBoxes + element.value.count
        }
    }
}

extension Double {
    func percent(upToDigits digits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.roundingMode = .halfUp
        formatter.maximumFractionDigits = digits
        
        return formatter.string(from: self as NSNumber)!
    }
}

extension Int {
    func decimal() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: self as NSNumber)!
    }
}
