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
        return Set(self.map { $0.label })
    }

    var imageNames: Set<String> {
        return Set(self.map { $0.name })
    }

    var stats: String {
        let gtBoxes = self.getBoundingBoxesByDetectionMode(.groundTruth)
        let detBoxes = self.getBoundingBoxesByDetectionMode(.detection)

        var description = "Global Stats\n".uppercased()
        description += "Ground Truth Count: \(gtBoxes.count)\n"
        description += "Detection Count:    \(detBoxes.count)\n"
        description += "Number of labels:   \(gtBoxes.labels.count)\n\n"

        description += labelStats

        return description
    }

    var labelStats: String {
        let gtBoxes = self.getBoundingBoxesByDetectionMode(.groundTruth)
        
        return gtBoxes.labels.sorted().reduce(into: "", { (descr, label) in
            let labelBoxes = gtBoxes.getBoundingBoxesByLabel(label)
            
            descr +=  "\(label.uppercased())\n"
            descr += "  Images:      \(labelBoxes.imageNames.count)\n"
            descr += "  Annotations: \(labelBoxes.count)\n\n"
        })
    }

    // MARK: - Methods
    func dispStats() {
        print(stats)
    }

    // MARK: - Methods
    func getBoundingBoxesByLabel(_ label: String) -> [BoundingBox] {
        return self.filter { $0.label == label }
    }

    func getBoundingBoxesByDetectionMode(_ detectionMode: DetectionMode) -> [BoundingBox] {
        return self.filter { $0.detectionMode == detectionMode }
    }

    func getBoundingBoxesByName(_ name: String) -> [BoundingBox] {
        return self.filter { $0.name == name }
    }

    func getBoxesDictByName() -> [String: [BoundingBox]] {
        return self.reduce(into: [:], { (dict, box) in
            dict[box.name, default: [box]].append(box)
        })
    }

    func getBoxesDictByLabel() -> [String: [BoundingBox]] {
        return self.reduce(into: [:], { (dict, box) in
            dict[box.name, default: [box]].append(box)
        })
    }

    mutating func mapLabels(with labels: [String: String]) {
        guard Set(labels.keys) == Set(self.labels) else {
            print("Error: new label keys must match old labels")
            return
        }

        self = self.map {
            BoundingBox(name: $0.name,
                        box: $0.box,
                        label: labels[$0.label]!,
                        coordSystem: .absolute,
                        confidence: $0.confidence,
                        imgSize: $0.imgSize)
        }
    }
}
