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
            try! Parser.parseYoloFolder($0)
        }
        evaluator.reset()
    }

    override func tearDown() { }

    func testPrecRec() {
//        evaluator.evaluate(on: boxes)
        
        let detection = evaluator.evaluations["maize"]!
        
        let tps = [true, true]
        let precisions = [1.0, 1.0]
        let recalls = [0.5, 1.0]
        
        XCTAssert(detection.nbGtPositive == 2, "Expected: \(2), got: \(detection.nbGtPositive)")
        
        for i in 0..<detection.nbDetections {
            let (tp, _, rec, prec) = detection[i]
            
            XCTAssert(tp == tps[i], "Expected: \(tps[i]), got: \(tp), iter: \(i)")
            XCTAssert(prec == precisions[i], "Expected: \(precisions[i]), got: \(prec), iter \(i)")
            XCTAssert(rec == recalls[i], "Expected: \(recalls[i]), got: \(rec), iter\(i)")
        }
    }

    func testEvaluation() {
        let boxes = urls.flatMap {
            try! Parser.parseYoloFolder($0)
        }
        self.measure {
            evaluator.evaluate(boxes)
        }
    }
    
    func testParser1() {
        self.measure {
            let _ = urls.flatMap {
                try! Parser.parseYoloFolder($0)
            }
        }
    }
    
    func testParser2() {
        self.measure {
            let _ = urls.flatMap {
                try! Parser2.parseFolder($0)
            }
        }
    }
    
    func testBoxesByImageName1() {
        self.measure {
            let _ = boxes.grouped(by: \.name)
        }
    }
}
