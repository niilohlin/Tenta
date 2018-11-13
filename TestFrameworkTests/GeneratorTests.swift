//
// Created by Niil Öhlin on 2018-10-09.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
import TestFramework
import XCTest

class GeneratorTests: XCTestCase {

    func testRunTest() {
        runTest(gen: Generator<Int>.int()) { int in
            int < 10
        }
    }

    func testRunMoreComplicatedIntTest() {
        runTest(gen: Generator<Int>.int()) { int in
            int < 21 || int % 2 == 1
        }
    }

    func testRunArray() {
        let intGenerator: Generator<Int> = Generator<Int>.int()
        runTest(gen: Generator<Int>.array(elementGenerator: intGenerator)) { array in
            print("got array count: \(array.count)")
            return array.count < 20
        }
    }

    func testFilterGenerator() {
        let positiveEvenGenerator = Generator<Int>.int().filter { int in
            (int > 0 && int % 2 == 0)
        }
        runTest(gen: positiveEvenGenerator) { positiveEven in
            XCTAssert(positiveEven > 0)
            XCTAssert(positiveEven % 2 == 0)
            return positiveEven > 0 && positiveEven % 2 == 0
        }
    }
}
