//
//  TestData.swift
//  YoloParser
//
//  Created by Louis Lac on 21/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

struct TestData {
    static var data = [
        // Ground Truths
        BoundingBox(name: "im_1.jpg", label: "maize", box: CGRect(x: 0, y: 0, width: 10, height: 10), coordSystem: .absolute),
        BoundingBox(name: "im_2.jpg", label: "maize", box: CGRect(x: 0, y: 0, width: 20, height: 20), coordSystem: .absolute),

        //Detections
        BoundingBox(name: "im_1.jpg", label: "maize", box: CGRect(x: 0, y: 0, width: 10, height: 10), coordSystem: .absolute, confidence: 0.9),
        BoundingBox(name: "im_2.jpg", label: "maize", box: CGRect(x: 0, y: 0, width: 20, height: 20), coordSystem: .absolute, confidence: 0.8),
    ]
}
