//
//  YoloParserErrors.swift
//  ObjectDetectionEvaluator
//
//  Created by Louis Lac on 07/09/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

enum YoloParserError: Error {
    case folderNotListable(_ folder: URL)
    case unreadableAnnotation(_ file: URL)
    case invalidLineFormat(file: URL, line: [String])
}
