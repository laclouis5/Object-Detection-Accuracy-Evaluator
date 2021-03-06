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
    var boxes = BoundingBoxes()
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
        nbGroundTruths.stringValue = "\(gts.count, style: .decimal)"
        nbDetections.stringValue = "\(dets.count, style: .decimal)"
        nbLabels.stringValue = "\(boxes.labels().count, style: .decimal)"
        
        // Detection result
        boxesStats.string = boxes.labelStats()
        
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
    
    func parseBoxes(
        from urls: [URL],
        coordType: CoordType,
        coordSystem: CoordinateSystem
    ) {
        boxes = []
        
        do {
            boxes = try urls.flatMap { url -> BoundingBoxes in
                try Parser2.parseFolder(
                    url,
                    coordType: coordType,
                    coordSystem: coordSystem
                )
            }
        } catch ParserError.folderNotListable(let url) {
            print("Error: folder '\(url)' not listable")
        } catch ParserError.unreadableAnnotation(let url) {
            print("Error: annotation '\(url)' not readable")
        } catch ParserError.invalidLineFormat(file: let url, line: let line) {
            print("Error: Line '\(line)' of file '\(url)' not readable")
        } catch {
            print("Unexpected error: \(error)")
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
        
        if dialog.runModal() == .OK {
            folders = dialog.urls
            evaluator.reset()
           
            update()
            workingIndicator.isHidden = false
            workingIndicator.startAnimation(self)
            
            let coordType = self.coordType
            let coordSystem = self.coordSystem
            DispatchQueue.global(qos: .userInitiated).async {
                self.parseBoxes(
                    from: self.folders,
                    coordType: coordType,
                    coordSystem: coordSystem
                )

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
        chooseFolderButton.isEnabled = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.evaluator.evaluate(self.boxes)
            
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
            // If coord did change just convert all boxes instead of parsing again
            self.parseBoxes(
                from: self.folders,
                coordType: coordType,
                coordSystem: coordSystem
            )

            DispatchQueue.main.async {
                self.update()
                self.workingIndicator.isHidden = true
                self.workingIndicator.stopAnimation(self)
                self.runEvaluationButton.isEnabled = true
            }
        }
    }
}
