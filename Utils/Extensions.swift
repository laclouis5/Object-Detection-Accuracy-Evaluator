//
//  Extensions.swift
//  ObjectDetectionEvaluator
//
//  Created by Louis Lac on 16/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

extension Sequence where Element == Bool {
    func cumSum() -> [Int] {
        var sum = 0
        var cumSum = [Int]()
        for bool in self {
            sum += bool ? 1 : 0
            cumSum.append(sum)
        }
        return cumSum
    }
}

extension Sequence where Element: AdditiveArithmetic {
    func cumSum() -> [Element] {
        var sum = Element.zero
        var cumSum = [Element]()
        for element in self {
            sum += element
            cumSum.append(sum)
        }
        return cumSum
    }
}

extension Sequence where Element: AdditiveArithmetic {
    func sum() -> Element {
        reduce(.zero, +)
    }
}

extension Collection where Element: FloatingPoint {
    func mean() -> Element {
        isEmpty ? .nan : sum() / Element(count)
    }
}

extension Collection where Element: BinaryInteger {
    func mean() -> Double {
        isEmpty ? .nan : Double(sum()) / Double(count)
    }
}

extension Collection {
    func mean<T: FloatingPoint>(for keyPath: KeyPath<Element, T>) -> T {
        isEmpty ? .nan : reduce(T.zero) { $0 + $1[keyPath: keyPath] } / T(count)
    }
}

extension Collection {
    func mean<T: BinaryInteger>(for keyPath: KeyPath<Element, T>) -> Double {
        isEmpty ? .nan : Double(reduce(T.zero) { $0 + $1[keyPath: keyPath] }) / Double(count)
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
