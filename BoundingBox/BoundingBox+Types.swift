//
//  BoundingBoxTypes.swift
//  YoloParser
//
//  Created by Louis Lac on 07/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

extension BoundingBox {
    /// `XYWH` case represents a bounding box by its center coordinates and box size while `XYX2Y2` represents it by its top-left and bottom-right coordinates.
    enum CoordType {
        case XYWH
        case XYX2Y2
    }

    /// Coordinates can be either absolute or relative to the image size.
    enum CoordinateSystem {
        case absolute
        case relative
    }

    /// Represents if a box is a prediction or a groud truth.
    enum DetectionMode {
        case groundTruth
        case detection
    }
}
