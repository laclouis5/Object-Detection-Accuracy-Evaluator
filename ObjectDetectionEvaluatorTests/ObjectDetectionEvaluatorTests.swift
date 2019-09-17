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

    let boxes     = TestData().data
    var evaluator = Evaluator()
    let urls      = [URL(string: "/Users/louislac/Downloads/detection-results")!,
                     URL(string: "/Users/louislac/Downloads/ground-truth")!]
    
    override func setUp() {
        evaluator.reset()
    }

    override func tearDown() {
    }

    func testPrecRec() {
        evaluator.evaluate(on: boxes, iouThresh: 0.5)
        
        let detection = evaluator.evaluations["maize"]!
        
        let tps        = [true, true]
        let precisions = [1.0, 1.0]
        let recalls    = [0.5, 1.0]
        
        XCTAssert(detection.nbGtPositive == 2, "Expected: \(2), got: \(detection.nbGtPositive)")
        
        for i in 0..<detection.nbDetections {
            let (tp, rec, prec) = detection[i]
            
            XCTAssert(tp == tps[i], "Expected: \(tps[i]), got: \(tp)")
            XCTAssert(prec == precisions[i], "Expected: \(precisions[i]), got: \(prec)")
            XCTAssert(rec == recalls[i], "Expected: \(recalls[i]), got: \(rec)")
        }
    }
    
    func testInferenceTime() {
        var boxes  = [BoundingBox]()
        let parser = Parser()
        
        for url in urls {
            boxes += try! parser.parseYoloFolder(url)
        }
        self.measure {
            evaluator.evaluate(on: boxes)
        }
    }
    
    func testCocoAP() {
        var boxes  = [BoundingBox]()
        let parser = Parser()
        
        for url in urls {
            boxes += try! parser.parseYoloFolder(url)
        }
        
        self.measure {
            let mAP = evaluator.evaluateCoco(on: boxes)
            print(mAP)
        }
    }
}
