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
    let evaluator = Evaluator()
    let urls      = [URL(string: "/Users/louislac/Downloads/detection-results")!,
                     URL(string: "/Users/louislac/Downloads/ground-truth")!]
    
    override func setUp() {
        evaluator.evaluate(on: boxes, iouTresh: 0.5)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPrecRec() {
        let detections = evaluator.evaluations["maize"]!.detections
        let gtCount    = 2.0
        let recalls    = [1/gtCount, 2/gtCount]
        let precisions = [1.0, 1.0]
        
        for (i, det) in detections.enumerated() {
            let precision = det.precision
            let recall    = det.recall
            
            XCTAssert(precision == precisions[i], "prec: \(precision), expected: \(precisions[i]), TP: \(det.TP), conf: \(det.confidence)")
            
            XCTAssert(recall == recalls[i], "rec: \(recall), expected: \(recalls[i]), TP: \(det.TP), conf: \(det.confidence)")
        }
    }
    
    func testAP() {
        for (_, evaluation) in evaluator.evaluations {
            let mAP = evaluation.mAP
            
            XCTAssert(mAP == 1.0, "Got: \(mAP)")
        }
    }

    func testYoloParserPerf() {
        // This is an example of a performance test case.
        let parser = Parser()
        self.measure {
            // Put the code you want to measure the time of here.
            _ = try! parser.parseYoloFolder(URL(string: "/Users/louislac/Downloads/detection-results")!)
        }
    }

    func testEvaluationPerf() {
        let parser    = Parser()
        let evaluator = Evaluator()
        var boxes     = [BoundingBox]()
       
        for url in urls {
            boxes += try! parser.parseYoloFolder(url)
        }
        
        self.measure {
            evaluator.evaluate(on: boxes)
        }
    }
}
