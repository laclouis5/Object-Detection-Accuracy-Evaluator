//
//  BoxTypes.swift
//  YoloParser
//
//  Created by Louis Lac on 07/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

struct Size: Hashable {
    let width, height: Int
}

enum CoordType {
    case XYWH
    case XYX2Y2
}

enum CoordinateSystem {
    case absolute
    case relative
}

enum DetectionMode {
    case groundTruth
    case detection
}
