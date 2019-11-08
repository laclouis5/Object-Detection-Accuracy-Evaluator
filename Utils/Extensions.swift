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

extension Array where Element: Numeric {
    var cumSum: [Element] {
        reduce(into: [Element]()) { (cumSum, element) in
            cumSum.append((cumSum.last ?? 0) + element)
        }
    }
}

extension Array where Element: FloatingPoint {
    var mean: Element {
        guard count != 0 else { return 0 }
        
        return reduce(0) {
            $0 + $1
        } / Element(count)
    }
}

extension Array {
    func mean<T: FloatingPoint>(for keyPath: KeyPath<Element, T>) -> T {
        guard count != 0 else { return 0 }
        
        return reduce(0) {
            $0 + $1[keyPath: keyPath]
        } / T(count)
    }
}

extension Dictionary where Value == [BoundingBox] {
    var nbBoundingBoxes: Int {
        reduce(0) { (nbBBoxes, element) -> Int in
            nbBBoxes + element.value.count
        }
    }
}

extension Sequence {
    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        map { $0[keyPath: keyPath] }
    }
}

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        sorted { a, b in
            a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}

extension Sequence {
    func sum<T: Numeric>(for keyPath: KeyPath<Element, T>) -> T {
        reduce(0) { sum, element in
            sum + element[keyPath: keyPath]
        }
    }
}

extension Sequence {
    func count(where predicate: (Element) throws -> Bool) rethrows -> Int {
        var count = 0
        for element in self {
            if try predicate(element) {
                count += 1
            }
        }
        return count
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

func stride(from start: Double, to stop: Double, count: Int) -> StrideTo<Double> {
    let step = (stop - start) / Double(count)
    return stride(from: start, to: stop, by: step)
}

func stride(from start: Double, through stop: Double, count: Int) -> StrideThrough<Double> {
    let step = (stop - start) / Double(count)
    return stride(from: start, through: stop, by: step)
}
