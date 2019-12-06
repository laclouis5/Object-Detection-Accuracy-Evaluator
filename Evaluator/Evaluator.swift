//
//  Evaluator.swift
//  YoloParser
//
//  Created by Louis Lac on 19/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

/// Object to evaluate mAP on a list on detection and ground truth bounding boxes.
struct Evaluator {
    //MARK: - Properties
    typealias Evaluations = [String: Evaluation]
    
    private let cocoThresholds = stride(from: 50, through: 95, by: 5).map { Double($0) / 100 }
    private(set) var evaluations = Evaluations()
    private(set) var cocoAP = 0.0
    
    //MARK: - Methods
    mutating func evaluate(_ boxes: [BoundingBox], method: EvaluationMethod = .iou) {
        let cocoEvaluations = cocoAP(boxes, method: method)
        cocoAP = cocoEvaluations.mean(for: \.mAP)
        evaluations = cocoEvaluations[0]
    }
    
    /// Returns Coco mAP @ `[0.5...0.95]`
    /// - Parameter boxes: Detection and ground truth boxes to be evaluated.
    /// - Parameter method: The method to evaluate true positive boxes.
    func cocoAP(_ boxes: [BoundingBox], method: EvaluationMethod = .iou) -> [Evaluations] {
        var cocoEvaluations = [Evaluations]()
        for thresh in cocoThresholds {
            let evaluation = self.AP(boxes, thresh: thresh, method: method)
            cocoEvaluations.append(evaluation)
        }
        return cocoEvaluations
    }
    
    /// Returns the total mAP at the specified threshold and evaluation method.
    /// - Parameter boxes: Detection and ground truth boxes to be evaluated.
    /// - Parameter thresh: IoU threshold or distance threshold depending on the specified method.
    /// - Parameter method: The method to evaluate true positive boxes.
    func AP(_ boxes: [BoundingBox], thresh: Double = 0.5, method: EvaluationMethod = .iou) -> Evaluations {
        var evaluations = Evaluations()
        for (label, bboxes) in boxes.grouped(by: \.label) {
            let (groundTruths, detections) = formatDetGT(boxes: bboxes)
            let truePositives = calcTpFp(groundTruths: groundTruths, detections: detections, method: method, thresh: thresh)
            let (recalls, precisions) = calcRecsPrecs(truePositives: truePositives, nbGtPositives: groundTruths.nbBoundingBoxes)
            let mAP = calcAP(precisions: precisions, recalls: recalls)

            evaluations[label] = Evaluation(nbGtPositive: groundTruths.nbBoundingBoxes, mAP: mAP, truePositives: truePositives, confidences: detections.map(\.confidence!), precisions: precisions, recalls: recalls)
        }
        return evaluations
    }
    
    /// Resets evaluations.
    mutating func reset() {
        evaluations.removeAll()
        cocoAP = 0.0
    }
    
    // MARK: - Private Methods
    private func formatDetGT(boxes: [BoundingBox]) -> ([String: [BoundingBox]], [BoundingBox]) {
        let (gts, dets) = boxes.gtsDets()
        return (gts?.grouped(by: \.name) ?? [:],
                dets?.sorted(by: \.confidence!, reversed: true) ?? [])
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
            let (recall, precision) = calcRecPrec(accTruePositives: tp, accDetections: i + 1, nbGtPositives: nbGtPositives)
            
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
        let recs = [0.0] + recalls + [1.0]
        
        for i in (0..<precs.count - 1).reversed() {
            precs[i] = max(precs[i], precs[i + 1])
        }
        var indexList = [Int]()
        
        for i in 1..<recs.count where recs[i] != recs[i - 1] {
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
