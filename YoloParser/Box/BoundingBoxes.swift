//
//  BoundingBoxes.swift
//  YoloParser
//
//  Created by Louis Lac on 15/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

extension Array where Element == Box {
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
        var descr = ""
        
        for label in gtBoxes.labels.sorted() {
            let labelBoxes = gtBoxes.getBoundingBoxesByLabel(label)
            
            descr +=  "\(label.uppercased())\n"
            descr += "  Images:      \(labelBoxes.imageNames.count)\n"
            descr += "  Annotations: \(labelBoxes.count)\n\n"
        }
        
        return descr
    }
    
    // MARK: - Methods
    func dispStats() {
        print(stats)
    }
    
    func getBoundingBoxesByLabel(_ label: String) -> [Box] {
        return self.filter { $0.label == label }
    }
    
    func getBoundingBoxesByDetectionMode(_ detectionMode: DetectionMode) -> [Box] {
        return self.filter { $0.detectionMode == detectionMode }
    }
    
    func getBoundingBoxesByName(_ name: String) -> [Box] {
        return self.filter { $0.name == name }
    }
    
    func getBoxesDictByName() -> [String: [Box]] {
        return self.reduce(into: [:], { (dict, box) in
            dict[box.name, default: [box]].append(box)
        })
    }
    
    func getBoxesDictByLabel() -> [String: [Box]] {
        return self.reduce(into: [:], { (dict, box) in
            dict[box.name, default: [box]].append(box)
        })
    }
    
    mutating func mapLabels(with labels: [String: String]) {
        // FIXME: Make this function to accept all kind of dict, not only String
        guard Set(labels.keys) == Set(self.labels) else {
            print("Error: new label keys must match old labels")
            return
        }
            
        self = self.map {
            // Boxes are always stored as absolute XYWH
            Box(name: $0.name,
                a: $0.x, b: $0.y, c: $0.w, d: $0.h,
                label: labels[$0.label]!,
                coordType: .XYWH,
                coordSystem: .absolute,
                confidence: $0.confidence,
                imgSize: $0.imgSize)
        }
    }
}
