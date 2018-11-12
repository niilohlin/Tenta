//
// Created by Niil Öhlin on 2018-10-16.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
@testable import TestFramework
import XCTest

class ShrinkTests: XCTestCase {
    func testHalves() {
        XCTAssertEqual(5.halves(), [5, 2, 1])
    }

    func testTowards() {
        XCTAssertEqual(0.towards(destination: 10), [0, 5, 8, 9])
    }

    func testTowards_backwards() {
        XCTAssertEqual(10.towards(destination: 0), [10, 5, 2, 1])
    }

    func testShrink() {
//        XCTAssertEqual((3.shrinkTowards(destination: 0)).flatMap(Array.init).map { $0.root() }, [0, 2, 0, 1, 0])
    }

    func testRemoving() {
        let array = [1, 2, 3, 4]
        XCTAssertEqual(array.removing(numberOfElements: 2), [[3, 4], [1, 2]])
    }

    func testRemoving1() {
        let array = [1, 2, 3, 4]
        XCTAssertEqual(array.removing(numberOfElements: 1), [[2, 3, 4], [1, 3, 4], [1, 2, 4], [1, 2, 3]])

    }

    func testSplitAt_firstHalf() {
        XCTAssertEqual([1, 2, 3, 4].splitAt(position: 2).0, [1, 2])
    }

    func testSplitAt_secondHalf() {
        XCTAssertEqual([1, 2, 3, 4].splitAt(position: 2).1, [3, 4])
    }

    func testShrinkArray() {
        let array = [1, 2, 3, 4]
        let expected = [[], [3, 4], [1, 2], [2, 3, 4], [1, 3, 4], [1, 2, 4], [1, 2, 3]]
        XCTAssertEqual(array.shrink(), expected)

    }
}
