//
//  Evaluator.swift
//  YoloParser
//
//  Created by Louis Lac on 19/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

class Evaluator {
    //MARK: - Properties
    var result = Evaluation()
    var detail = [String: Evaluation]()
    
    //MARK: - Methods
    func evaluate(on boxes: [Box], iouTresh: Double = 0.5) {
        let allGroundTruths = boxes
            .getBoundingBoxesByDetectionMode(.groundTruth)
        let allDetections = boxes
            .getBoundingBoxesByDetectionMode(.detection)
        
        for label in boxes.labels {
            var truePositiveNumber = 0
            
            // Gts boxes for label 'label'
            let groundTruths = allGroundTruths
                .getBoundingBoxesByLabel(label)
                .getBoxesDictByName()
            
            // Detections by decreasing confidence for label 'label'
            let detections = allDetections
                .getBoundingBoxesByLabel(label)
                .sorted { $1.confidence! < $0.confidence! }
            
            // Counter for already visited gts
            var counter = groundTruths.mapValues { [Bool](repeating: false, count: $0.count) }
            
            // Init evaluation and store 'totalPositive'
            var evaluation = Evaluation(for: label, reservingCapacity: detections.count)
            
            evaluation.totalPositive = boxes
                .getBoundingBoxesByDetectionMode(.groundTruth)
                .getBoundingBoxesByLabel(label)
                .count
            
            // Loop through detections
            for detection in detections {
                // Retreive gts in the same image, if there is
                let associatedGts = groundTruths[detection.name] ?? []
                
                // Find the gt box with greatest IoU
                var maxIoU = 0.0
                var index = 0
                
                for (i, groundTruth) in associatedGts.enumerated() {
                    let iou = detection.computeIoU(with: groundTruth)
                    // Find the greatest IoU
                    if iou > maxIoU {
                        maxIoU = iou
                        index = i
                    }
                }
                
                // If gt box is not already associated and IoU threshold is triggered compute precision and recall and mark the gt box as visited and as TP
                let visited = counter[detection.name]?[index] ?? true
                
                // Mark as TP
                if maxIoU >= iouTresh && !visited {
                    evaluation.truePositives.append(true)
                    counter[detection.name]![index] = true
                    truePositiveNumber += 1
                
                // Else mark box as FP
                } else {
                    evaluation.truePositives.append(false)
                }
                
                let falsePositiveNumber = evaluation.truePositives.count - truePositiveNumber
                
                let (precision, recall) = computePrecRec(tp: truePositiveNumber, fp: falsePositiveNumber, totalPositive: evaluation.totalPositive)
                
                // Update evaluation
                evaluation.recalls.append(recall)
                evaluation.precisions.append(precision)
            }
            
            // Save evaluation
            detail[label] = evaluation
        }
    }
    
    func reset() {
        detail = [:]
        result = Evaluation()
    }
    
    private func computePrecRec(tp: Int, fp: Int, totalPositive: Int) -> (Double, Double) {
        let precision = Double(tp) / (Double(tp) + Double(fp))
        let recall = Double(tp) / Double(totalPositive)
        
        return (precision, recall)
    }
}

extension Evaluator: CustomStringConvertible {
    var description: String {
        var description = ""
        
        for label in detail.keys.sorted() {
            description += detail[label]!.description + "\n"
        }
        
        return description
    }
}
