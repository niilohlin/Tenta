//
//  RoseTreeTests.swift
//  TestFramework
//
//  Created by Niil Öhlin on 2018-10-09.
//  Copyright © 2018 Niil Öhlin. All rights reserved.
//

import Foundation
import XCTest
@testable import TestFramework

class RoseTreeTests: XCTestCase {
    func testRose() {
        let rose = RoseTree(root: { 0 }, forest: { [
            RoseTree(root: {1}, forest: { [
                RoseTree(root: {3}, forest: { [] })
                ] }),
            RoseTree(root: {2}, forest: { [
                RoseTree(root: {4}, forest: { [] })
                ] })
            ]})
        let array = Array(rose)
        XCTAssertEqual(array, [0, 1, 2, 3, 4])

    }
}
