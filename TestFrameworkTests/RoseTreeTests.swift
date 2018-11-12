//
//  RoseTreeTests.swift
//  TestFramework
//
//  Created by Niil Öhlin on 2018-10-09.
//  Copyright © 2018 Niil Öhlin. All rights reserved.
//

import Foundation
@testable import TestFramework
import XCTest

class RoseTreeTests: XCTestCase {
    func testRose() {
        let rose = RoseTree(root: { 0 }, forest: { [
            RoseTree(root: { 1 }, forest: { [
                RoseTree(root: { 3 }, forest: { [] })
                ] }),
            RoseTree(root: { 2 }, forest: { [
                RoseTree(root: { 4 }, forest: { [] })
                ] })
            ]})
        let array = Array(rose).map { $0.root() }
        XCTAssertEqual(array, [0, 1, 2, 3, 4])
    }

    func testMapRose() {
        let rose = RoseTree(root: { 0 }, forest: { [
            RoseTree(root: { 1 }, forest: { [
                RoseTree(root: { 3 }, forest: { [] })
            ] }),
            RoseTree(root: { 2 }, forest: { [
                RoseTree(root: { 4 }, forest: { [] })
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

    func testFlatMap() {
        let rose = RoseTree<Int>(seed: 1) { value in
            [value * -2, value * 2]
        }
        let flatMapped = rose.flatMap { (int: Int) -> RoseTree<String> in
            RoseTree<String>(root: { "\(int)" }, forest: {
                [RoseTree<String>(root: { "\(int) is an int" }, forest: { [RoseTree<String>]() }),
                 RoseTree<String>(root: { "\(int) is fun" }, forest: { [RoseTree<String>]() })
                ]
            })
        }
        XCTAssertEqual(flatMapped.prefix(5).map { $0.root() }, ["1", "1 is an int", "1 is fun", "-2", "2"])

    }

    func testSequence() {
        let forest = (0..<5).map { int in RoseTree(root: { int }) }
        let array = RoseTree<Int>.sequence(forest: forest).root()
        XCTAssertEqual(array, [0, 1, 2, 3, 4])
    }

    func testBigSequence() {
        let firstTree = RoseTree<Int>(root: { 0 }, forest: {
            [RoseTree<Int>(root: { 1 }), RoseTree<Int>(root: { 2 })]
        })
        let secondTree = RoseTree<Int>(root: { 3 }, forest: {
            [RoseTree<Int>(root: { 4 }), RoseTree<Int>(root: { 5 })]
        })
        let forest = [firstTree, secondTree]
        let roseTree = RoseTree<Int>.sequence(forest: forest)
        XCTAssertEqual(Array(roseTree).map { $0.root() }, [[0, 3], [0, 4], [0, 5], [1, 3], [2, 3], [1, 4], [1, 5], [2, 4], [2, 5]])
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
