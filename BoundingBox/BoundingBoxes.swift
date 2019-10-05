//
//  BoundingBoxes.swift
//  YoloParser
//
//  Created by Louis Lac on 15/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

extension Array where Element == BoundingBox {
    // MARK: - Computed Properties
    var labels: Set<String> {
        Set(map { $0.label })
    }

    var imageNames: Set<String> {
        Set(map { $0.name })
    }
    
    var detections: [BoundingBox] {
        filter { $0.detectionMode == .detection }
    }
    
    var groundTruths: [BoundingBox] {
        filter { $0.detectionMode == .groundTruth }
    }
    
    var boxesByImgName: [String: [BoundingBox]] {
        reduce(into: [:]) { (dict, box) in
            dict[box.name, default: []].append(box)
        }
    }

    var boxesByLabel: [String: [BoundingBox]] {
        reduce(into: [:]) { (dict, box) in
            dict[box.label, default: []].append(box)
        }
    }

    var stats: String {
        var description = "Global Stats\n".uppercased()
        description += "Ground Truth Count: \(detections.count)\n"
        description += "Detection Count:    \(groundTruths.count)\n"
        description += "Number of labels:   \(groundTruths.labels.count)\n\n"

        description += labelStats

        return description
    }

    var labelStats: String {
        boxesByLabel
            .keys
            .sorted()
            .reduce(into: "") { (description, label) in
            description += label.uppercased() + "\n"
            description += "  Images:      \(boxesByLabel[label]!.imageNames.count)\n"
            description += "  Annotations: \(boxesByLabel[label]!.count)\n\n"
        }
    }

    // MARK: - Methods
    mutating func mapLabels(with labels: [String: String]) {
        guard Set(labels.keys) == Set(self.labels) else {
            print("Error: new label keys must match old labels")
            print("Old Labels: \(self.labels)")
            print("Given labels: \(labels.keys)")
            return
        }
        self = map {
            BoundingBox(imgName: $0.name, label: labels[$0.label]!, box: $0.box, coordSystem: $0.coordSystem, confidence: $0.confidence, imgSize: $0.imgSize)
        }
    }
}
