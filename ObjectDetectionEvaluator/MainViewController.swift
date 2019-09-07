//
//  MainViewController.swift
//  ObjectDetectionEvaluator
//
//  Created by Louis Lac on 07/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    var yoloFolders: [URL]!
    var boxes: [Box]!
    
    @IBOutlet weak var nbGroundTruths: NSTextField!
    @IBOutlet weak var nbDetections: NSTextField!
    @IBOutlet weak var nbLabels: NSTextField!
    @IBOutlet weak var boxesStats: NSTextView!
    @IBOutlet weak var folderPath: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yoloFolders = []
        boxes       = []
        update()
    }
    
    func update() {
        nbGroundTruths.stringValue = String(boxes.getBoundingBoxesByDetectionMode(.groundTruth).count)
        nbDetections.stringValue   = String(boxes.getBoundingBoxesByDetectionMode(.detection).count)
        nbLabels.stringValue       = String(boxes.labels.count)
        
        boxesStats.string = boxes.labelStats
        
        if yoloFolders.count == 0 {
            folderPath.stringValue = "No folder seleted..."
        } else if yoloFolders.count == 1 {
            folderPath.stringValue = "\(yoloFolders.count) folder selected"
        } else {
            folderPath.stringValue = "\(yoloFolders.count) folders selected"
        }
    }
    
    func parseBoxes(from urls: [URL]) {
        let parser = Parser()
        
    }
    
    @IBAction func browseFile(sender: AnyObject) {
        let dialog = NSOpenPanel();
        
        dialog.canChooseFiles          = false
        dialog.showsResizeIndicator    = true
        dialog.canChooseDirectories    = true
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = true
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let urls = dialog.urls
            print(urls)
            yoloFolders = urls
            update()
        }
    }
}
