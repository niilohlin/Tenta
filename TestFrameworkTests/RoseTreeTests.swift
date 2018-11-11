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
        let array = Array(rose).map { $0.root() }
        XCTAssertEqual(array, [0, 1, 2, 3, 4])
    }

    func testMapRose() {
        let rose = RoseTree(root: { 0 }, forest: { [
            RoseTree(root: {1}, forest: { [
                RoseTree(root: {3}, forest: { [] })
            ] }),
            RoseTree(root: {2}, forest: { [
                RoseTree(root: {4}, forest: { [] })
            ] })
        ]})

        let array = Array(rose.map { $0 * 2 }).map { $0.root() }
        XCTAssertEqual(array, [0, 2, 4, 6, 8])

    }

    func testInitWithGenerator() {
        let rose = RoseTree<Int>(seed: 1) { value in
            [value * -2, value * 2]
        }

        XCTAssertEqual(rose.prefix(5).map { $0.root() }, [1, -2, 2, 4, -4])
    }

    func testExpand() {
        let rose = RoseTree<Int>(seed: 1) { value in
            [value * -2, value * 2]
        }

        let expanded = rose.expand { x in [x + 1, x - 1] }
        XCTAssertEqual(expanded.prefix(10).map { $0.root() }, [1, -2, 2, 2, 0, 4, -4, -1, -3, -4])

    }

//    func testExpandRose() {
//        let doubleFunc = { (i: Int) -> [Int] in
//            [-i * 2, i * 2]
//        }
//        let tree = RoseTree<Int>.expandTree(initial: 1, doubleFunc)
//        var results = [Int]()
//        for subRose in tree {
//            results.append(subRose.root())
//            if results.count > 8 {
//                break
//            }
//        }
//        print("results: \(results)")
//    }
}
