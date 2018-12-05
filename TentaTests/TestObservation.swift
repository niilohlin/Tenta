//
// Created by Niil Öhlin on 2018-12-04.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
import XCTest

class TestObservation: NSObject, XCTestObservation {
    override init() {
        super.init()
        XCTestObservationCenter.shared.addTestObserver(self)
    }
    public func testCase(
            _ testCase: XCTestCase,
            didFailWithDescription description: String,
            inFile filePath: String?,
            atLine lineNumber: Int
    ) {
        print("failed! \(testCase)")
    }
}
