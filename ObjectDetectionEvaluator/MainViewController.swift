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
    var yoloFolders: [URL]?
    var boxes: [BoundingBox]?
    var evaluator: Evaluator!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        evaluator = Evaluator()
        
        workingIndicator.isHidden = true
        evalutationIndicator.isHidden = true
        runEvaluationButton.isEnabled = false
        
        update()
    }
    
    // MARK: - Methods
    func update() {
        // Folder
        switch yoloFolders?.count {
        case nil, 0:
            folderPath.stringValue = "No folder selected..."
        case 1:
            folderPath.stringValue = "1 folder selected"
        case let count?:
            folderPath.stringValue = "\(count) folders selected"
        }
        
        // General Stats
        nbGroundTruths.stringValue = String(boxes?.getBoundingBoxesByDetectionMode(.groundTruth).count ?? 0)
        nbDetections.stringValue = String(boxes?.getBoundingBoxesByDetectionMode(.detection).count ?? 0)
        nbLabels.stringValue = String(boxes?.labels.count ?? 0)
        
        // Detection result
        boxesStats.string = boxes?.labelStats ?? ""
        
        // Detail of Evaluation
        switch boxes?.count {
        case nil, 0:
            runEvaluationButton.isEnabled = false
        default:
            runEvaluationButton.isEnabled = true
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
            boxes = nil
        } catch YoloParserError.unreadableAnnotation(let url) {
            print("Error: annotation '\(url)' not readable")
            boxes = nil
        } catch YoloParserError.invalidLineFormat(file: let url, line: let line) {
            print("Error: Line '\(line)' of file '\(url)' not readable")
            boxes = nil
        } catch let error {
            print("Error while reading annotations: \(error)")
            boxes = nil
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
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            // Check if folders have changed
            yoloFolders = dialog.urls
            update()
            
            guard let folders = yoloFolders else { return }
            
            if Set(folders) != Set(dialog.urls) {
                evaluator.reset()
            }
            
            workingIndicator.isHidden = false
            workingIndicator.startAnimation(self)
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.parseBoxes(from: folders)
                let newlabels = ["0": "Maize",
                                 "1": "Bean",
                                 "2": "Leek",
                                 "3": "Stem Maize",
                                 "4": "Stem Bean",
                                 "5": "Stem Leek"]
                
                self.boxes?.mapLabels(with: newlabels)
                
                DispatchQueue.main.async {
                    self.update()
                    self.workingIndicator.isHidden = true
                    self.workingIndicator.stopAnimation(self)
                }
            }
        }
    }
    
    @IBAction func runEvaluation(_ sender: Any) {
        guard let boxes = self.boxes else { return }
        
        evalutationIndicator.isHidden = false
        evalutationIndicator.startAnimation(self)
        runEvaluationButton.isEnabled = false
        
        evaluator.reset()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.evaluator.evaluate(on: boxes, method: .center, thresh: 20/1536)
            
            DispatchQueue.main.async {
                self.update()
                
                self.evalutationIndicator.isHidden = true
                self.evalutationIndicator.stopAnimation(self)
                self.runEvaluationButton.isEnabled = true
            }
        }
    }
}
