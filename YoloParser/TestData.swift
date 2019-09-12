//
//  TestData.swift
//  YoloParser
//
//  Created by Louis Lac on 21/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

class TestData {
    var data: [Box]
    
    init() {
        data = [Box]()
        
        // Ground Truths
        data.append(Box(name: "im_1.jpg", a: 0, b: 0, c: 10, d: 10, label: "maize", coordType: .XYX2Y2, coordSystem: .absolute))
        data.append(Box(name: "im_2.jpg", a: 0, b: 0, c: 20, d: 20, label: "maize", coordType: .XYX2Y2, coordSystem: .absolute))
        data.append(Box(name: "im_3.jpg", a: 0, b: 0, c: 30, d: 30, label: "maize", coordType: .XYX2Y2, coordSystem: .absolute))
        data.append(Box(name: "im_4.jpg", a: 0, b: 0, c: 40, d: 40, label: "maize", coordType: .XYX2Y2, coordSystem: .absolute))
        
        // Detections
        data.append(Box(name: "im_4.jpg", a: 0, b: 0, c: 40, d: 40, label: "maize", coordType: .XYX2Y2, coordSystem: .absolute, confidence: 0.5))
        data.append(Box(name: "im_1.jpg", a: 0, b: 0, c: 10, d: 10, label: "maize", coordType: .XYX2Y2, coordSystem: .absolute, confidence: 0.9))
        data.append(Box(name: "im_2.jpg", a: 0, b: 0, c: 20, d: 20, label: "maize", coordType: .XYX2Y2, coordSystem: .absolute, confidence: 0.8))
        data.append(Box(name: "im_3.jpg", a: 0, b: 0, c: 30, d: 30, label: "maize", coordType: .XYX2Y2, coordSystem: .absolute, confidence: 0.7))
        data.append(Box(name: "im_4.jpg", a: 0, b: 0, c: 40, d: 40, label: "maize", coordType: .XYX2Y2, coordSystem: .absolute, confidence: 0.6))
    }
}
