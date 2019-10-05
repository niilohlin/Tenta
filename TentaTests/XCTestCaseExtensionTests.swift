//
// Created by Niil Öhlin on 2018-12-05.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
import Tenta
import XCTest

class XCTestCaseExtensionTests: XCTestCase {
    func testRunWithXCTest() {
        runWithXCTest(generator: [Int].generator) { (ints: [Int]) in
            XCTAssertEqual(ints.sorted(), ints.sorted().sorted())
        }
    }

    func testRunWithXCTest_defaultGenerator() {
        runWithXCTest { (int: Int, char: Character) in
            XCTAssertNotEqual(String(describing: int) + String(char), "")
        }
    }

    func testRunTestWithDifferentTestSize() {
        seed = 0
        numberOfTests = 1
        let expect = expectation(description: "should only be called once")
        runWithXCTest { (int: Int) in
            XCTAssertNotEqual(int, 100, "should not generate and int of size 100 on the first try")
            expect.fulfill()
        }
        wait(for: [expect], timeout: 0.1)
    }

    // Example of failing test.
    func disabled_testUpperCasedLowerCased() {
        numberOfTests = 10000

        runWithXCTest { (int: UInt32) in
            guard let scalar = Unicode.Scalar(int) else {
                return
            }
            let char = Character(scalar)
            let string = String(char)

            XCTAssertEqual(string.uppercased(), string.lowercased().uppercased())
        }
    }
}
