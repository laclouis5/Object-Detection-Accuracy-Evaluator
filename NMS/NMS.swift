//
//  NMS.swift
//  ObjectDetectionEvaluator
//
//  Created by Louis Lac on 23/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

/// Returns filtered boxes with Non Maximum Suppression algorithm.
/// - Parameter boxes: Detection boxes to filter.
/// - Parameter nmsThresh: Threshold on Intersection over Union used to merge boxes. Must be between 0 and 1.
func performNMS(on boxes: [BoundingBox], nmsThresh: Double) throws -> [BoundingBox] {
    // FIXME: Must process each label independantly (in parallel)
    // TODO: Implement Fast NSM
    // FIXME: Maybe create a struct/class or integrate to BoundingBoxes as a filtering method
    
    guard boxes.allSatisfy({ (box) -> Bool in
        box.detectionMode == .detection
    }) else { throw NMSError.areNotDetectionBoxes }
    
    let filteredBoxes = boxes
        .sorted { $0.confidence! > $1.confidence! }
    
    var outBoxes = [BoundingBox]()
    
    for box1 in filteredBoxes {
        var keep = true
        
        for box2 in outBoxes where keep == true {
            let overlap = box1.iou(with: box2)
            keep = overlap > nmsThresh
        }
        if keep {
            outBoxes.append(box1)
        }
    }
    return outBoxes
}
