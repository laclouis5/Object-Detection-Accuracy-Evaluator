//
//  MainViewController.swift
//  ObjectDetectionEvaluator
//
//  Created by Louis Lac on 07/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    var boxes: [Box]!
    
    @IBOutlet weak var nbGroundTruths: NSTextField!
    @IBOutlet weak var nbDetections: NSTextField!
    @IBOutlet weak var nbLabels: NSTextField!
    @IBOutlet var boxesStats: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        update()
    }
    
    func update() {
        nbGroundTruths.stringValue = String(boxes.getBoundingBoxesByDetectionMode(.groundTruth).count)
        nbDetections.stringValue = String(boxes.getBoundingBoxesByDetectionMode(.detection).count)
        nbLabels.stringValue = String(boxes.labels.count)
        boxesStats.string = boxes.labelStats
    }
    
    func setup() {
        let basePath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
        let pathGT = basePath.appendingPathComponent("ground-truth")
        let pathDet = basePath.appendingPathComponent("detection-results")
        
        do {
            let parser = Parser()
            
            boxes = try parser.parseYoloFolder(pathGT)
            boxes += try parser.parseYoloFolder(pathDet)
            
            boxes.dispStats()
            
        } catch {
            print("Error while reading files")
        }
    }
}
