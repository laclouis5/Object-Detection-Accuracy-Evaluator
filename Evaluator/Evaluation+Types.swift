//
//  EvaluationTypes.swift
//  ObjectDetectionEvaluator
//
//  Created by Louis Lac on 17/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

/// The method to evaluate mAP and accuracy. `iou` is the standard Intersection over Union metric while `center` is based on the distance between 2 bounding boxes center.
enum EvaluationMethod {
    case iou
    case center
}
