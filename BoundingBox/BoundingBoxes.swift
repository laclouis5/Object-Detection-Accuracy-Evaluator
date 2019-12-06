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
        Set(map(\.label))
    }

    var imageNames: Set<String> {
        Set(map(\.name))
    }
    
    func gtsDets() -> (groundTruths: [BoundingBox]?, detections: [BoundingBox]?) {
        let boxesByDetectionMode = self.grouped(by: \.detectionMode)
        let gts = boxesByDetectionMode[.groundTruth]
        let dets = boxesByDetectionMode[.detection]
        return (gts, dets)
    }

    var stats: String {
        let (gts, dets) = gtsDets()
        
        var description = "Global Stats\n".uppercased()
        description += "Ground Truth Count: \(gts?.count ?? 0, style: .decimal)\n"
        description += "Detection Count:    \(dets?.count ?? 0, style: .decimal)\n"
        description += "Number of labels:   \(gts?.labels.count ?? 0, style: .decimal)\n\n"
        description += labelStats

        return description
    }

    var labelStats: String {
        let boxesByLabel = self.grouped(by: \.label)
        return boxesByLabel.keys.sorted().reduce(into: "") { (description, label) in
            description += label.uppercased() + "\n"
            description += "  Images:      \(boxesByLabel[label]!.imageNames.count, style: .decimal)\n"
            description += "  Annotations: \(boxesByLabel[label]!.count, style: .decimal)\n\n"
        }
    }

    // MARK: - Methods
    mutating func mapLabels(with labels: [String: String]) {
        guard Set(labels.keys) == self.labels else {
            print("Error: new label keys must match old labels")
            print("Old Labels: \(self.labels)")
            print("Given labels: \(labels.keys)")
            return
        }
        self = map {
            BoundingBox(name: $0.name, label: labels[$0.label]!, box: $0.box, coordSystem: $0.coordSystem, confidence: $0.confidence, imgSize: $0.imgSize)
        }
    }
    
    // MARK: - Stubs
    static func stub() -> [BoundingBox] {
        var boxes = [BoundingBox]()
        
        for i in 0..<10 {
            let name = "im_\(i).jpg"
            let label = i < 5 ? "maize" : "bean"
            let gtBox = BoundingBox(name: name, label: label, box: CGRect(midX: 100 * (1 + i), midY: 100 * (1 + i), width: 50, height: 50), coordSystem: .absolute)
            let detBox = BoundingBox(name: name, label: label, box: CGRect(midX: 100 * (1 + i), midY: 100 * (1 + i), width: 50, height: 50), coordSystem: .absolute, confidence: 0.9)
            boxes.append(gtBox)
            boxes.append(detBox)
        }
        return boxes
    }
}
