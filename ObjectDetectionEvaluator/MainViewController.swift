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
    var yoloFolders: [URL]!
    var boxes: [BoundingBox]!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yoloFolders = []
        boxes       = []
        evaluator   = Evaluator()
        
        workingIndicator.isHidden     = true
        evalutationIndicator.isHidden = true
        runEvaluationButton.isEnabled = false
        
        update()
    }
    
    // MARK: - Methods
    func update() {
        // Folder
        if yoloFolders.count == 0 {
            folderPath.stringValue = "No folder selected..."
        } else if yoloFolders.count == 1 {
            folderPath.stringValue = "\(yoloFolders.count) folder selected"
        } else {
            folderPath.stringValue = "\(yoloFolders.count) folders selected"
        }
        
        // General Stats
        nbGroundTruths.stringValue = String(boxes.getBoundingBoxesByDetectionMode(.groundTruth).count)
        nbDetections.stringValue   = String(boxes.getBoundingBoxesByDetectionMode(.detection).count)
        nbLabels.stringValue       = String(boxes.labels.count)
        
        // Detail of Boxes
        boxesStats.string = boxes.labelStats
        
        // Detail of Evaluation
        if boxes.count != 0 {
            runEvaluationButton.isEnabled = true
        } else {
            runEvaluationButton.isEnabled = false
        }
        
        evalutationStats.string = evaluator.description
        
    }
    
    func parseBoxes(from urls: [URL]) {
        let parser = Parser()
        
        boxes = urls.flatMap({ (url) -> [BoundingBox] in
            do {
                return try parser.parseYoloFolder(url, coordType: .XYWH, coordSystem: .relative)
            } catch YoloParserError.folderNotListable(let folder) {
                print("Error: Unable to read folder \(folder). Check permissions.")
                return []
            } catch YoloParserError.unreadableAnnotation(let annotation) {
                print("Error: Unable to read file \(annotation). Check permissions.")
                return []
            } catch YoloParserError.invalidLineFormat(let file, let line) {
                print("Error: Unable to read line \(line) of file \(file). Read the documentation to know more about Yolo annotation format.")
                return []
            } catch {
                print("Unknown error.")
                return []
            }
        })
    }
    
    // MARK: - Actions
    @IBAction func browseFile(sender: AnyObject) {
        let dialog = NSOpenPanel();
        
        dialog.canChooseFiles          = false
        dialog.showsResizeIndicator    = true
        dialog.canChooseDirectories    = true
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = true
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            yoloFolders = dialog.urls
            update()
            
            workingIndicator.isHidden = false
            workingIndicator.startAnimation(self)
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.parseBoxes(from: self.yoloFolders)
                
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
        
        evaluator.reset()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.evaluator.evaluate(on: self.boxes, method: .center, thresh: 20/1536)
            
            DispatchQueue.main.async {
                self.update()
                self.evalutationIndicator.isHidden = true
                self.evalutationIndicator.stopAnimation(self)
                self.runEvaluationButton.isEnabled = true
            }
        }
    }
}
