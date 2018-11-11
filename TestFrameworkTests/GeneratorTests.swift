//
// Created by Niil Öhlin on 2018-10-09.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
import XCTest
@testable import TestFramework

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
        runTest(gen: IntGenerator()) { int in
            int < 10
        }
    }

    func testRunMoreComplicatedIntTest() {
        runTest(gen: IntGenerator()) { int in
            int < 21 || int % 2 == 1
        }
    }
}
