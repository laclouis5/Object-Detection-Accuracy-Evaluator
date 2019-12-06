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
    
    var coordType: CoordType {
        switch coordTypeSegmentedControl.selectedSegment {
        case 0:
            return .XYWH
        case 1:
            return .XYX2Y2
        default:
            fatalError()
        }
    }
    var coordSystem: CoordinateSystem {
        switch coordSystemSegmentedControl.selectedSegment {
        case 0:
            return .relative
        case 1:
            return .absolute
        default:
            fatalError()
        }
    }
    
    // TODO: Implement state and observers
    
    // MARK: - Outlets
    @IBOutlet weak var folderPath: NSTextField!
    @IBOutlet weak var coordTypeSegmentedControl: NSSegmentedControl!
    @IBOutlet weak var coordSystemSegmentedControl: NSSegmentedControl!
    @IBOutlet weak var workingIndicator: NSProgressIndicator!
    @IBOutlet weak var chooseFolderButton: NSButtonCell!
    
    @IBOutlet weak var nbGroundTruths: NSTextField!
    @IBOutlet weak var nbDetections: NSTextField!
    @IBOutlet weak var nbLabels: NSTextField!
    
    @IBOutlet var boxesStats: NSTextView!
    
    @IBOutlet var evalutationStats: NSTextView!
    @IBOutlet weak var runEvaluationButton: NSButton!
    @IBOutlet weak var evalutationIndicator: NSProgressIndicator!
    @IBOutlet weak var totalMAP: NSTextField!
    @IBOutlet weak var cocoAP: NSTextField!
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        workingIndicator.isHidden = true
        evalutationIndicator.isHidden = true
        runEvaluationButton.isEnabled = false
        chooseFolderButton.isEnabled = true
        
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
            folderPath.stringValue = "\(count, style: .decimal) folders selected"
        }
        
        // General Stats
        let (gts, dets) = boxes.gtsDets()
        nbGroundTruths.stringValue = "\(gts?.count ?? 0, style: .decimal)"
        nbDetections.stringValue = "\(dets?.count ?? 0, style: .decimal)"
        nbLabels.stringValue = "\(boxes.labels.count, style: .decimal)"
        
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
        totalMAP.stringValue = "\(evaluator.evaluations.mAP, style: .percent)"
        cocoAP.stringValue = "\(evaluator.cocoAP, style: .percent)"
    }
    
    func parseBoxes(from urls: [URL], coordType: CoordType, coordSystem: CoordinateSystem) {
        do {
            boxes = try urls.flatMap { url -> [BoundingBox] in
                try Parser.parseYoloFolder(url, coordType: coordType, coordSystem: coordSystem)
            }
        } catch Parser.Error.folderNotListable(let url) {
            print("Error: folder '\(url)' not listable")
            boxes = []
        } catch Parser.Error.unreadableAnnotation(let url) {
            print("Error: annotation '\(url)' not readable")
            boxes = []
        } catch Parser.Error.invalidLineFormat(file: let url, line: let line) {
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
            runEvaluationButton.isEnabled = false
            
            let coordType = self.coordType
            let coordSystem = self.coordSystem
            DispatchQueue.global(qos: .userInitiated).async {
                self.parseBoxes(from: self.folders, coordType: coordType, coordSystem: coordSystem)

                DispatchQueue.main.async {
                    self.update()
                    self.workingIndicator.isHidden = true
                    self.workingIndicator.stopAnimation(self)
                    self.runEvaluationButton.isEnabled = true
                }
            }
        }
    }
    
    @IBAction func runEvaluation(_ sender: Any) {
        evalutationIndicator.isHidden = false
        evalutationIndicator.startAnimation(self)
        runEvaluationButton.isEnabled = false
        chooseFolderButton.isEnabled = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.evaluator.evaluate(self.boxes)
            
//            self.evaluator.evaluate(on: self.boxes, method: .center, thresh: 20/1536)
            
            DispatchQueue.main.async {
                self.update()
                self.evalutationIndicator.isHidden = true
                self.evalutationIndicator.stopAnimation(self)
                self.runEvaluationButton.isEnabled = true
                self.chooseFolderButton.isEnabled = true
            }
        }
    }
    
    @IBAction func coordTypeDidChange(_ sender: Any) {
        // Ugly because repeated code
        evaluator.reset()
        update()
        
        workingIndicator.isHidden = false
        workingIndicator.startAnimation(self)
        runEvaluationButton.isEnabled = false
        
        let coordType = self.coordType
        let coordSystem = self.coordSystem
        DispatchQueue.global(qos: .userInitiated).async {
            self.parseBoxes(from: self.folders, coordType: coordType, coordSystem: coordSystem)

            DispatchQueue.main.async {
                self.update()
                self.workingIndicator.isHidden = true
                self.workingIndicator.stopAnimation(self)
                self.runEvaluationButton.isEnabled = true
            }
        }
    }
}
