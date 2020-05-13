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
    private var cocoThresholds: [Double] {
        stride(from: 50, through: 95, by: 5).map {
            Double($0) / 100
        }
    }
    private(set) var evaluations = Evaluations()
    private(set) var cocoAP = Double.nan
    
    //MARK: - Methods
    mutating func evaluate(_ boxes: BoundingBoxes) {
        let cocoEvaluations = cocoAP(boxes)
        cocoAP = cocoEvaluations.mean(for: \.mAP)
        evaluations = cocoEvaluations[0]
    }
    
    /// Returns Coco mAP @ `[0.5...0.95]`
    /// - Parameter boxes: Detection and ground truth boxes to be evaluated.
    /// - Parameter method: The method to evaluate true positive boxes.
    func cocoAP(_ boxes: BoundingBoxes) -> [Evaluations] {
        var cocoEvaluations = [Evaluations](repeating: .init(), count: cocoThresholds.count)
        
        DispatchQueue.concurrentPerform(iterations: cocoThresholds.count) { index in
            let thresh = cocoThresholds[index]
            let evaluation = self.AP(boxes, thresh: thresh)
            cocoEvaluations[index] = evaluation
        }
        
        return cocoEvaluations
    }
    
    /// Returns the total mAP at the specified threshold and evaluation method.
    /// - Parameter boxes: Detection and ground truth boxes to be evaluated.
    /// - Parameter thresh: IoU threshold or distance threshold depending on the specified method.
    /// - Parameter method: The method to evaluate true positive boxes.
    func AP(
        _ boxes: BoundingBoxes,
        thresh: Double = 0.5,
        method: EvaluationMethod = .iou
    ) -> Evaluations {
        var evaluations = Evaluations()
        
        for (label, bboxes) in boxes.grouped(by: \.label) {
            let (groundTruths, detections) = formatDetGT(boxes: bboxes)
            let truePositives = calcTpFp(
                groundTruths: groundTruths,
                detections: detections,
                method: method, thresh: thresh
            )
            let (recalls, precisions) = calcRecsPrecs(
                truePositives: truePositives,
                nbGtPositives: groundTruths.nbBoundingBoxes
            )
            let mAP = calcAP(precisions: precisions, recalls: recalls)

            evaluations[label] = Evaluation(
                nbGtPositive: groundTruths.nbBoundingBoxes,
                mAP: mAP,
                truePositives: truePositives,
                confidences: detections.map(\.confidence!),
                precisions: precisions,
                recalls: recalls
            )
        }
        
        return evaluations
    }
    
    /// Resets evaluations.
    mutating func reset() {
        evaluations.removeAll()
        cocoAP = Double.nan
    }
    
    // MARK: - Private Methods
    typealias BoxesDict = [String: BoundingBoxes]
    private func formatDetGT(boxes: BoundingBoxes) -> (BoxesDict, BoundingBoxes) {
        let (gts, dets) = boxes.gtsDets()
        
        return (
            gts.grouped(by: \.name),
            dets.sorted(by: \.confidence!, reversed: true)
        )
    }
    
    private func calcTpFp(
        groundTruths: BoxesDict,
        detections: BoundingBoxes,
        method: EvaluationMethod,
        thresh: Double
    ) -> [Bool] {
        var truePositives = [Bool](repeating: false, count: detections.count)
        var isVisited = groundTruths.mapValues { boxes in
            [Bool](repeating: false, count: boxes.count)
        }

        for (i, detection) in detections.enumerated() {
            // If no gt continue
            guard let assotiatedGts = groundTruths[detection.name] else {
                continue
            }
            
            var index: Int
            
            switch method {
            case .iou:
                let ious = assotiatedGts.map { detection.iou(with: $0) }
                index = ious.indices.max(by: { ious[$0] < ious[$1] })!
                let maxIou = ious[index]

                guard maxIou >= thresh else { continue }
                
            case .center:
                let distances = assotiatedGts.map { detection.distance(to: $0) }
                index = distances.indices.min(by: { distances[$0] < distances[$1] })!
                let minDist = distances[index]
                
                guard minDist <= thresh else { continue }
            }
            
            guard !isVisited[detection.name]![index] else { continue }
            
            isVisited[detection.name]![index] = true
            truePositives[i] = true
        }
        return truePositives
    }
    
    private func calcRecsPrecs(
        truePositives: [Bool],
        nbGtPositives: Int
    ) -> ([Double], [Double]) {
        var precisions = [Double]()
        var recalls = [Double]()
        
        precisions.reserveCapacity(truePositives.count)
        recalls.reserveCapacity(truePositives.count)
        
        let tpAcc = truePositives.cumSum()
        
        for (i, tp) in tpAcc.enumerated() {
            let (recall, precision) = calcRecPrec(
                accTruePositives: tp,
                accDetections: i + 1,
                nbGtPositives: nbGtPositives
            )
            
            recalls.append(recall)
            precisions.append(precision)
        }
        
        return (recalls, precisions)
    }
    
    private func calcRecPrec(
        accTruePositives: Int,
        accDetections: Int,
        nbGtPositives: Int
    ) -> (Double, Double) {
        let precision = Double(accTruePositives) / Double(accDetections)
        let recall = nbGtPositives != 0 ?
            Double(accTruePositives) / Double(nbGtPositives) : 0
        
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
    
    private func calcLabelAP(
        boxes: BoundingBoxes,
        thresh: Double = 0.5,
        method: EvaluationMethod = .iou
    ) -> Double {
        let (groundTruths, detections) = formatDetGT(boxes: boxes)
        
        let truePositives = calcTpFp(
            groundTruths: groundTruths,
            detections: detections,
            method: .iou,
            thresh: thresh
        )
        
        let (recalls, precisions) = calcRecsPrecs(
            truePositives: truePositives,
            nbGtPositives: groundTruths.nbBoundingBoxes
        )
        
        let AP = calcAP(precisions: precisions, recalls: recalls)
        
        return AP
    }
    
    private func calcFMesure(recall: Double, precision: Double) -> Double {
        guard precision + recall == 0 else { return 0 }
        
        return 2 * recall * precision / (precision + recall)
    }
}
