//
// Created by Niil Öhlin on 2018-10-14.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
@testable import TestFramework
import XCTest

class SeededRandomNumberGeneratorTests: XCTestCase {
    func testRandomNumberGenerator_returnsDifferent() {

        var rng = SeededRandomNumberGenerator(seed: 100)
        let firstValue = rng.next()
        let secondValue = rng.next()

        XCTAssertNotEqual(firstValue, secondValue)
    }

    func testRandomNumberGenerator_withIntegers() {
        var rng = SeededRandomNumberGenerator(seed: 100)

        let array = (0..<10).map { _ in
            Int.random(in: 0..<100, using: &rng)
        }
        XCTAssertEqual(array, [63, 26, 29, 72, 27, 66, 77, 28, 55, 54])
    }
}
