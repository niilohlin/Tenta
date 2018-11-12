//
// Created by Niil Öhlin on 2018-10-09.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
@testable import TestFramework
import XCTest

class GeneratorTests: XCTestCase {

    func testGenerateInts() {
//        let rose = generateIntegers(range: Range(uncheckedBounds: (lower: 0, upper: 1)))
//        var i = 0
//        for element in rose {
//            i += 1
//            if i > 20 {
//                break
//            }
//            print("element: \(i) = \(element)")
//        }
    }

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
        let intGenerator: Generator<Int, SeededRandomNumberGenerator> = Generator<Int, SeededRandomNumberGenerator>.int()
        runTest(gen: Generator<Int, SeededRandomNumberGenerator>.array(elementGenerator: intGenerator)) { array in
            print("got array: \(array)")
            return !array.contains { $0 > 30 }
        }
    }
}
