//
//  Extensions.swift
//  ObjectDetectionEvaluator
//
//  Created by Louis Lac on 16/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

extension Array where Element == Bool {
    // Should be a func as complexity is O(n)
    var cumSum: [Int] {
        reduce(into: [Int]()) { (cumSum, bool) in
            cumSum.append((cumSum.last ?? 0) + (bool ? 1 : 0))
        }
    }
}

extension Array where Element: AdditiveArithmetic {
    // Should be a func as complexity is O(n)
    var cumSum: [Element] {
        reduce(into: [Element]()) { (cumSum, element) in
            cumSum.append((cumSum.last ?? Element.zero) + element)
        }
    }
}

extension Array where Element: FloatingPoint {
    func mean() -> Element {
        isEmpty ? 0 : reduce(0) { $0 + $1 } / Element(count)
    }
}

extension Array {
    func mean<T: FloatingPoint>(for keyPath: KeyPath<Element, T>) -> T {
        isEmpty ? 0 : reduce(0) { $0 + $1[keyPath: keyPath] } / T(count)
    }
}

extension Dictionary where Value == [BoundingBox] {
    // Should be a func as complexity is O(n)
    var nbBoundingBoxes: Int {
        reduce(0) { (nbBoxes, element) -> Int in
            nbBoxes + element.value.count
        }
    }
}

extension Sequence {
    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        map { $0[keyPath: keyPath] }
    }
}

extension Sequence {
    func grouped<T>(by keyPath: KeyPath<Element, T>) -> [T: [Element]] {
        Dictionary(grouping: self, by: { $0[keyPath: keyPath] })
    }
}

extension Sequence {
    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T>,
        reversed: Bool = false
    ) -> [Element] {
        let method: (T, T) -> Bool = reversed ? (>) : (<)
        return sorted { a, b in
            method(a[keyPath: keyPath], b[keyPath: keyPath])
        }
    }
}

extension Sequence {
    func sum<T: AdditiveArithmetic>(for keyPath: KeyPath<Element, T>) -> T {
        reduce(T.zero) { sum, element in
            sum + element[keyPath: keyPath]
        }
    }
}

extension Sequence {
    func count(where predicate: (Element) throws -> Bool) rethrows -> Int {
        var count = 0
        for element in self where try predicate(element) {
            count += 1
        }
        return count
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation<T: Numeric>(
        _ number: T,
        style: NumberFormatter.Style
    ) {
        let formatter = NumberFormatter()
        formatter.numberStyle = style
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .halfDown
        
        if let result = formatter.string(from: number as! NSNumber) {
            appendLiteral(result)
        }
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
