//
//  MainViewController.swift
//  ObjectDetectionEvaluator
//
//  Created by Louis Lac on 07/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    // MARK: - Properties
    var folders = [URL]()
    var boxes = [BoundingBox]()
    var evaluator = Evaluator()
    
    // MARK: - Outlets
    @IBOutlet weak var folderPath: NSTextField!
    @IBOutlet weak var workingIndicator: NSProgressIndicator!
    
    @IBOutlet weak var nbGroundTruths: NSTextField!
    @IBOutlet weak var nbDetections: NSTextField!
    @IBOutlet weak var nbLabels: NSTextField!
    
    @IBOutlet var boxesStats: NSTextView!
    
    @IBOutlet var evalutationStats: NSTextView!
    @IBOutlet weak var runEvaluationButton: NSButton!
    @IBOutlet weak var evalutationIndicator: NSProgressIndicator!
    @IBOutlet weak var totalMAP: NSTextField!
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        workingIndicator.isHidden = true
        evalutationIndicator.isHidden = true
        runEvaluationButton.isEnabled = false
        
        update()
    }

    func update() {
        // Folder
        switch folders.count {
        case 0:
            folderPath.stringValue = "No folder selected..."
        case 1:
            folderPath.stringValue = "1 folder selected"
        case let count:
            folderPath.stringValue = "\(count) folders selected"
        }
        
        // General Stats
        nbGroundTruths.stringValue = String(boxes.groundTruths.count)
        nbDetections.stringValue = String(boxes.detections.count)
        nbLabels.stringValue = String(boxes.labels.count)
        
        // Detection result
        boxesStats.string = boxes.labelStats
        
        // Detail of Evaluation
        switch boxes.count {
        case 0:
            runEvaluationButton.isEnabled = false
        case 1...:
            runEvaluationButton.isEnabled = true
        default:
            runEvaluationButton.isEnabled = false
            print("Error: boxes not initialized.")
        }
        evalutationStats.string = evaluator.description
        totalMAP.stringValue = "\(Double(Int(10_000 * evaluator.evaluations.mAP)) / 100) %"
    }
    
    func parseBoxes(from urls: [URL]) {
        do {
            boxes = try urls.flatMap { url -> [BoundingBox] in
                try Parser.parseYoloFolder(url, coordType: .XYWH, coordSystem: .relative)
            }
        } catch YoloParserError.folderNotListable(let url) {
            print("Error: folder '\(url)' not listable")
            boxes = []
        } catch YoloParserError.unreadableAnnotation(let url) {
            print("Error: annotation '\(url)' not readable")
            boxes = []
        } catch YoloParserError.invalidLineFormat(file: let url, line: let line) {
            print("Error: Line '\(line)' of file '\(url)' not readable")
        } catch let error {
            print("Error while reading annotations: \(error)")
            boxes = []
        }
    }
    
    // MARK: - Actions
    @IBAction func browseFile(sender: AnyObject) {
        let dialog = NSOpenPanel()
        
        dialog.canChooseFiles = false
        dialog.showsResizeIndicator = true
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = false
        dialog.allowsMultipleSelection = true
        
        if (dialog.runModal() == .OK) {
            folders = dialog.urls
            evaluator.reset()
            update()
            
            workingIndicator.isHidden = false
            workingIndicator.startAnimation(self)
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.parseBoxes(from: self.folders)
                let newlabels = [
                    "0": "Maize",
                    "1": "Bean",
                    "2": "Leek",
                    "3": "Stem Maize",
                    "4": "Stem Bean",
                    "5": "Stem Leek"
                ]
                
                self.boxes.mapLabels(with: newlabels)
                
                DispatchQueue.main.async {
                    self.update()
                    self.workingIndicator.isHidden = true
                    self.workingIndicator.stopAnimation(self)
                }
            }
        }
    }
    
    @IBAction func runEvaluation(_ sender: Any) {
        evalutationIndicator.isHidden = false
        evalutationIndicator.startAnimation(self)
        runEvaluationButton.isEnabled = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.evaluator.evaluate(on: self.boxes, thresh: 0.5, method: .iou)
//            self.evaluator.evaluate(on: self.boxes, method: .center, thresh: 20/1536)
            
            DispatchQueue.main.async {
                self.update()
                self.evalutationIndicator.isHidden = true
                self.evalutationIndicator.stopAnimation(self)
                self.runEvaluationButton.isEnabled = true
            }
        }
    }
}
