//
//  Evaluator.swift
//  YoloParser
//
//  Created by Louis Lac on 19/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

// May be an extention of [String : Evaluation]
struct Evaluator {

    //MARK: - Properties
    var evaluations = [String: Evaluation]()
    
    func evaluateCoco(on boxes: [BoundingBox], method: EvaluationMethod = .iou) -> Double {
        // Can be parallelized
        let iouThresholds = Array(0..<10).map { Double($0) / 10 + 0.05 }
        var mAP = [Double]()
        
        for (_, bboxes) in boxes.getBoxesDictByLabel() {
            let groundTruths   = bboxes.getBoundingBoxesByDetectionMode(.groundTruth).getBoxesDictByName()
            let nbGroundTruths = bboxes.getBoundingBoxesByDetectionMode(.groundTruth).count
            let detections     = bboxes.getBoundingBoxesByDetectionMode(.detection).sorted {
                $0.confidence! > $1.confidence!
            }
            
            for thresh in iouThresholds {
                let truePositives         = calcTpFp(groundTruths: groundTruths, detections: detections, method: method, thresh: thresh)
                let (recalls, precisions) = calcRecPrec(truePositives: truePositives, nbGtPositives: nbGroundTruths)
                let AP                    = calcAP(precisions: precisions, recalls: recalls)
            
                mAP.append(AP)
            }
        }
        
        return mAP.reduce(0.0, +) / Double(mAP.count)
    }
    
    mutating func evaluate(on boxes: [BoundingBox], method: EvaluationMethod = .iou, thresh: Double = 0.5) {
        for (label, bboxes) in boxes.getBoxesDictByLabel() {
            let groundTruths   = bboxes.getBoundingBoxesByDetectionMode(.groundTruth).getBoxesDictByName()
            let nbGroundTruths = bboxes.getBoundingBoxesByDetectionMode(.groundTruth).count
            let detections     = bboxes.getBoundingBoxesByDetectionMode(.detection).sorted {
                $0.confidence! > $1.confidence!
            }

            let truePositives         = calcTpFp(groundTruths: groundTruths, detections: detections, method: method, thresh: thresh)
            let (recalls, precisions) = calcRecPrec(truePositives: truePositives, nbGtPositives: nbGroundTruths)
            let mAP                   = calcAP(precisions: precisions, recalls: recalls)

            evaluations[label] = Evaluation(nbGtPositive: nbGroundTruths, mAP: mAP, truePositives: truePositives, precisions: precisions, recalls: recalls)
        }
    }
    
    private func calcTpFp(groundTruths: [String: [BoundingBox]], detections: [BoundingBox], method: EvaluationMethod, thresh: Double) -> [Bool] {
        var counter       = groundTruths.mapValues { [Bool](repeating: false, count: $0.count) }
        var truePositives = [Bool]()
        truePositives.reserveCapacity(detections.count)
        
        for detection in detections {
            // Retreive gts in the same image, if there is
            let associatedGts = groundTruths[detection.name] ?? []
            var maxThresh: Double
            var index = 0
            
            switch method {
            case .iou:
                maxThresh = 0.0
                for (i, groundTruth) in associatedGts.enumerated() {
                    let iou = detection.distance(with: groundTruth)
                
                    // Find the greatest IoU
                    if iou > maxThresh {
                        maxThresh = iou
                        index = i
                    }
                }
                
                let visited = counter[detection.name]?[index] ?? true
                
                if maxThresh >= thresh && !visited {
                    // Mark as TP
                    truePositives.append(true)
                    counter[detection.name]![index] = true
                } else {
                    truePositives.append(false)
                }
                
            case .center:
                maxThresh = Double.infinity
                for (i, groundTruth) in associatedGts.enumerated() {
                    let distance = detection.distance(with: groundTruth)
                    
                    if distance < maxThresh {
                        maxThresh = distance
                        index = i
                    }
                }
                let visited = counter[detection.name]?[index] ?? true
                
                if maxThresh <= thresh && !visited {
                    // Mark as TP
                    truePositives.append(true)
                    counter[detection.name]![index] = true
                } else {
                    truePositives.append(false)
                }
            }
        }
        
        return truePositives
    }
    
    private func calcRecPrec(truePositives: [Bool], nbGtPositives: Int) -> ([Double], [Double]) {
        var precisions = [Double]()
        var recalls    = [Double]()
        
        precisions.reserveCapacity(truePositives.count)
        recalls.reserveCapacity(truePositives.count)
        
        let tpAcc = truePositives.cumSum
        
        for (i, tp) in tpAcc.enumerated() {
            let (recall, precision) = recPrec(accTruePositives: tp, accDetections: i+1, nbGtPositives: nbGtPositives)
            recalls.append(recall)
            precisions.append(precision)
        }
        
        return (recalls, precisions)
    }
    
    private func recPrec(accTruePositives: Int, accDetections: Int, nbGtPositives: Int) -> (Double, Double) {
        let precision = Double(accTruePositives) / Double(accDetections)
        let recall    = nbGtPositives != 0 ? Double(accTruePositives) / Double(nbGtPositives) : 0
        
        return (recall, precision)
    }
    
    private func calcAP(precisions: [Double], recalls: [Double]) -> Double {
        var mAP = 0.0
        
        var precs = [0.0] + precisions + [0.0]
        var recs  = [0.0] + recalls    + [1.0]
        
        for i in (0..<precs.count-1).reversed() {
            precs[i] = max(precs[i], precs[i+1])
        }
        
        var indexList = [Int]()
        
        for i in 1..<recs.count {
            if recs[i] != recs[i-1] {
                indexList.append(i)
            }
        }
        
        for i in indexList {
            mAP += (recs[i] - recs[i-1]) * precs[i]
        }
        
        return mAP
    }
    
    mutating func reset() {
        evaluations = [:]
    }
}
