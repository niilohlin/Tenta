//
// Created by Niil Öhlin on 2018-10-09.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
@testable import TestFramework
import XCTest

class GeneratorTests: XCTestCase {

    func testRunTest() {
        runTest(gen: Generator<Int, SeededRandomNumberGenerator>.int()) { int in
            int < 10
        }
    }

    func testRunMoreComplicatedIntTest() {
        runTest(gen: Generator<Int, SeededRandomNumberGenerator>.int()) { int in
            int < 21 || int % 2 == 1
        }
    }

    func testRunArray() {
        let intGenerator: Generator<Int, SeededRandomNumberGenerator> =
                Generator<Int, SeededRandomNumberGenerator>.int()
        runTest(gen: Generator<Int, SeededRandomNumberGenerator>.array(elementGenerator: intGenerator)) { array in
            print("got array count: \(array.count)")
            return array.count < 20
        }
    }
}
