//
// Created by Niil Öhlin on 2018-10-16.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
import XCTest
@testable import TestFramework

class ShrinkTests: XCTestCase {
    func testHalves() {
        XCTAssertEqual(5.halves(), [5, 2, 1])
    }

    func testTowards() {
        XCTAssertEqual(0.towards(destination: 10), [0, 5, 8, 9])
    }

    func testShrink() {
        XCTAssertEqual((3.shrinkTowards(destination: 0)).flatMap(Array.init), [0, 2, 0, 1, 0])
    }
}