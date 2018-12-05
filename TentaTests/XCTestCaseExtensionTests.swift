//
// Created by Niil Öhlin on 2018-12-05.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
import Tenta
import XCTest

class XCTestCaseExtensionTests: XCTestCase {
    func testRunWithXCTest() {
        runWithXCTest(gen: [Int].generator) { (ints: [Int]) in
            XCTAssertEqual(ints.sorted(), ints.sorted().sorted())
        }
    }

    func testRunWithXCTest_defaultGenerator() {
        runWithXCTest { (int: Int, char: Character) in
            XCTAssertNotEqual(String(describing: int) + String(char), "")
        }
    }
}
