//
//  Evaluation.swift
//  YoloParser
//
//  Created by Louis Lac on 07/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

struct Evaluation {
    var totalPositive = 0
    var detections    = [DetectionResult]()
    
    init() { }
    
    // Reserve capacity to avoid copy overhead with large collections
    init(reservingCapacity capacity: Int) {
        detections.reserveCapacity(capacity)
    }
    
    var mAP: Double {
        // Base on VOC 2012 Matlab code:
        // mrec=[0 ; rec ; 1];
        // mpre=[0 ; prec ; 0];
        // for i=numel(mpre)-1:-1:1
        //     mpre(i)=max(mpre(i),mpre(i+1));
        // end
        // i=find(mrec(2:end)~=mrec(1:end-1))+1;
        // ap=sum((mrec(i)-mrec(i-1)).*mpre(i));
        var mAP = 0.0
        
        var precisions = [0.0] + detections.map{ $0.precision } + [0.0]
        var recalls    = [0.0] + detections.map{ $0.recall } + [1.0]
        
        for i in (0..<precisions.count-1).reversed() {
            precisions[i] = max(precisions[i], precisions[i+1])
        }
        
        var indexList = [Int]()
        
        for i in 1..<recalls.count {
            if recalls[i] != recalls[i-1] {
                indexList.append(i)
            }
        }
        
        for i in indexList {
            mAP += (recalls[i] - recalls[i-1]) * precisions[i]
        }
        
        return mAP
    }
}

extension Evaluation: CustomStringConvertible {
    var description: String {
        var description = ""
        description += "mAP: \(mAP) %\n"
        description += "  Total Positive: \(totalPositive)\n"
        description += "  True Positive:  \(detections.filter { $0.TP }.count)\n"
        description += "  False Positive: \(detections.count - detections.filter { $0.TP }.count)\n"
        
        return description
    }
}
