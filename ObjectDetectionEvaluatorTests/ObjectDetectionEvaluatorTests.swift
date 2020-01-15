//
//  ObjectDetectionEvaluatorTests.swift
//  ObjectDetectionEvaluatorTests
//
//  Created by Louis Lac on 07/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import XCTest
@testable import ObjectDetectionEvaluator

class ObjectDetectionEvaluatorTests: XCTestCase {
    var boxes = [BoundingBox]()
    var evaluator = Evaluator()

    let folders = [
        "Yolo_V3_Tiny_Pan_Mixup_1/detections/",
        "Yolo_V3_Tiny_Pan_Mixup_1/gts/"
    ]
    
    var urls: [URL] {
        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        return folders.map { desktopURL.appendingPathComponent($0) }
    }
    
    override func setUp() {
        boxes = urls.flatMap {
            try! Parser2.parseFolder($0)
        }
        evaluator.reset()
    }

    override func tearDown() { }

    func testEvaluation() {
        self.measure {
            evaluator.evaluate(boxes)
        }
    }
    
    func testParser1() {
        self.measure {
            _ = urls.flatMap {
                try! Parser.parseFolder($0)
            }
        }
    }
    
    func testParser2() {
        self.measure {
            _ = urls.flatMap {
                try! Parser2.parseFolder($0)
            }
        }
    }
    
    func testBoxesByImageName1() {
        self.measure {
            _ = boxes.grouped(by: \.name)
        }
    }
    
    func testCumSum() {
        let bools: [Bool] = (0..<100_000).map { _ in Bool.random() }
        
        self.measure {
            _ = bools.cumSum()
        }
    }
    
    func testArrayMean() {
        let ints: [Double] = (0..<100_000).map { _ in Double.random(in: 0..<10) }
        
        self.measure {
            _ = ints.mean(for: \.self)
        }
    }
}
