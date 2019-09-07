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
    var evaluator: Evaluator!
    
    @IBOutlet weak var nbGroundTruths: NSTextField!
    @IBOutlet weak var nbDetections: NSTextField!
    @IBOutlet weak var nbLabels: NSTextField!
    @IBOutlet var boxesStats: NSTextView!
    @IBOutlet weak var folderPath: NSTextField!
    @IBOutlet var evalutationStats: NSTextView!
    @IBOutlet weak var workingIndicator: NSProgressIndicator!
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
    
    func update() {
        // Folder Part
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
        boxes = []
        
        for url in urls {
            do {
                boxes += try parser.parseYoloFolder(url)
            } catch YoloParserError.folderNotListable(let folder) {
                print("Error: Unable to read folder \(folder). Check permissions.")
            } catch YoloParserError.unreadableAnnotation(let annotation) {
                print("Error: Unable to read file \(annotation). Check permissions.")
            } catch YoloParserError.invalidLineFormat(let file, let line) {
                print("Error: Unable to read line \(line) of file \(file). Read the documentation to know more about Yolo annotation format.")
            } catch {print("Unkwnown error")}
        }
    }
    
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
            
            DispatchQueue.global(qos: .background).async {
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
        
        DispatchQueue.global(qos: .background).async {
            self.evaluator.evaluate(on: self.boxes)
            DispatchQueue.main.async {
                self.update()
                self.evalutationIndicator.isHidden = true
                self.evalutationIndicator.stopAnimation(self)
            }
        }
    }
}
