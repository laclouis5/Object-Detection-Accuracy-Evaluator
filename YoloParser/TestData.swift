//
//  TestData.swift
//  YoloParser
//
//  Created by Louis Lac on 21/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

class TestData {
    var data: [BoundingBox]

    init() {
        data = [BoundingBox]()

        // Ground Truths
        data.append(BoundingBox(name: "im_1.jpg", box: CGRect(x: 0, y: 0, width: 10, height: 10), label: "maize", coordSystem: .absolute))
        data.append(BoundingBox(name: "im_2.jpg", box: CGRect(x: 0, y: 0, width: 10, height: 10), label: "maize", coordSystem: .absolute))

        // Detections
        data.append(BoundingBox(name: "im_1.jpg", box: CGRect(x: 0, y: 0, width: 10, height: 10), label: "maize", coordSystem: .absolute, confidence: 0.9))
        data.append(BoundingBox(name: "im_2.jpg", box: CGRect(x: 0, y: 0, width: 10, height: 10), label: "maize", coordSystem: .absolute, confidence: 0.9))
    }
}
