//
// Created by Niil Öhlin on 2018-10-14.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
@testable import Tenta
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
        XCTAssertEqual(array, [57, 87, 90, 56, 56, 52, 56, 29, 17, 63])
    }

    func testClone() {
        var rng = SeededRandomNumberGenerator(seed: 100)
        var clone = rng.clone()
        XCTAssertNotEqual(rng.next(), clone.next())
    }
}
