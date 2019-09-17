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
        return self.reduce(into: [Int]()) { (cumSum, bool) in
            cumSum.append((cumSum.last ?? 0) + (bool ? 1 : 0))}
    }
}

extension Array where Element == Int {
    var cumSum: [Int] {
        return self.reduce(into: [Int]()) { (cumSum, element) in
            cumSum.append((cumSum.last ?? 0) + element)
        }
    }
}

extension Array where Element == Double {
    var mean: Double {
        return self.reduce(0.0, +) / Double(self.count)
    }
}

extension Dictionary where Value == [BoundingBox] {
    var nbBoundingBoxes: Int {
        return self.reduce(0) { (nbBBoxes, element) -> Int in
            return nbBBoxes + element.value.count
        }
    }
}
