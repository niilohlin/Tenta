//
// Created by Niil Öhlin on 2018-12-18.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public enum TestResult<TestedType> {
    case succeeded
    case failed(value: TestedType, shrunkValue: TestedType, shrinks: Int)
}
