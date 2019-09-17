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
        return self.reduce(into: [Int](), { (cumSum, element) in
            cumSum.append((cumSum.last ?? 0) + element)
        })
    }
}
