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
    
    //MARK: - Methods
    func evaluateAP(on boxes: [BoundingBox], thresh: Double = 0.5, method: EvaluationMethod = .iou) -> Double {
        var mAP = [Double]()
        
        for (_, bboxes) in boxes.getBoxesDictByLabel() {
            let AP = calcLabelAP(boxes: bboxes, thresh: thresh, method: method)
            mAP.append(AP)
        }
        return mAP.mean
    }
    
    func evaluateCocoAP(on boxes: [BoundingBox], method: EvaluationMethod = .iou) -> Double {
        let iouThresholds = stride(from: 0.05, to: 1, by: 0.10)
        var mAP = [Double]()
        
        for (_, bboxes) in boxes.getBoxesDictByLabel() {
            let (groundTruths, detections) = formatDetGT(boxes: bboxes)
            for thresh in iouThresholds {
                let truePositives = calcTpFp(groundTruths: groundTruths, detections: detections, method: method, thresh: thresh)
                let (recalls, precisions) = calcRecsPrecs(truePositives: truePositives, nbGtPositives: groundTruths.nbBoundingBoxes)
                let AP = calcAP(precisions: precisions, recalls: recalls)
                
                mAP.append(AP)
            }
        }
        return mAP.mean
    }
    
    mutating func evaluate(on boxes: [BoundingBox], method: EvaluationMethod = .iou, thresh: Double = 0.5) {
        for (label, bboxes) in boxes.getBoxesDictByLabel() {
            let (groundTruths, detections) = formatDetGT(boxes: bboxes)
            let truePositives = calcTpFp(groundTruths: groundTruths, detections: detections, method: method, thresh: thresh)
            let (recalls, precisions) = calcRecsPrecs(truePositives: truePositives, nbGtPositives: groundTruths.nbBoundingBoxes)
            let mAP = calcAP(precisions: precisions, recalls: recalls)

            evaluations[label] = Evaluation(nbGtPositive: groundTruths.nbBoundingBoxes, mAP: mAP, truePositives: truePositives, confidences: detections.map { $0.confidence! }, precisions: precisions, recalls: recalls)
        }
    }
    
    mutating func reset() {
        evaluations = [:]
    }
    
    // MARK: - Private Methods
    private func formatDetGT(boxes: [BoundingBox]) -> ([String: [BoundingBox]], [BoundingBox]) {
        let groundTruths = boxes.getBoundingBoxesByDetectionMode(.groundTruth).getBoxesDictByName()
        let detections = boxes.getBoundingBoxesByDetectionMode(.detection).sorted {
            $0.confidence! > $1.confidence!
        }
        return (groundTruths, detections)
    }
    
    private func calcTpFp(groundTruths: [String: [BoundingBox]], detections: [BoundingBox], method: EvaluationMethod, thresh: Double) -> [Bool] {
        
        var counter = groundTruths.mapValues { [Bool](repeating: false, count: $0.count) }
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
                    let iou = detection.iou(with: groundTruth)
                
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
    
    private func calcRecsPrecs(truePositives: [Bool], nbGtPositives: Int) -> ([Double], [Double]) {
        var precisions = [Double]()
        var recalls = [Double]()
        
        precisions.reserveCapacity(truePositives.count)
        recalls.reserveCapacity(truePositives.count)
        
        let tpAcc = truePositives.cumSum
        
        for (i, tp) in tpAcc.enumerated() {
            let (recall, precision) = calcRecPrec(accTruePositives: tp, accDetections: i+1, nbGtPositives: nbGtPositives)
            
            recalls.append(recall)
            precisions.append(precision)
        }
        return (recalls, precisions)
    }
    
    private func calcRecPrec(accTruePositives: Int, accDetections: Int, nbGtPositives: Int) -> (Double, Double) {
        let precision = Double(accTruePositives) / Double(accDetections)
        let recall = nbGtPositives != 0 ? Double(accTruePositives) / Double(nbGtPositives) : 0
        
        return (recall, precision)
    }
    
    private func calcAP(precisions: [Double], recalls: [Double]) -> Double {
        var mAP = 0.0
        
        var precs = [0.0] + precisions + [0.0]
        let recs = [0.0] + recalls    + [1.0]
        
        for i in (0..<precs.count-1).reversed() {
            precs[i] = max(precs[i], precs[i+1])
        }
        var indexList = [Int]()
        
        for i in 1..<recs.count where recs[i] != recs[i-1] {
            indexList.append(i)
        }
        for i in indexList {
            mAP += (recs[i] - recs[i-1]) * precs[i]
        }
        return mAP
    }
    
    private func calcLabelAP(boxes: [BoundingBox], thresh: Double = 0.5, method: EvaluationMethod = .iou) -> Double {
        let (groundTruths, detections) = formatDetGT(boxes: boxes)
        let truePositives = calcTpFp(groundTruths: groundTruths, detections: detections, method: .iou, thresh: thresh)
        let (recalls, precisions) = calcRecsPrecs(truePositives: truePositives, nbGtPositives: groundTruths.nbBoundingBoxes)
        let AP = calcAP(precisions: precisions, recalls: recalls)
        
        return AP
    }
    
    private func calcFMesure(recall: Double, precision: Double) -> Double {
        guard precision + recall == 0 else { return 0 }
        return 2 * recall * precision / (precision + recall)
    }
}
