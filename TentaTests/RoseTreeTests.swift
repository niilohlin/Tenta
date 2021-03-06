//
//  RoseTreeTests.swift
//  Tenta
//
//  Created by Niil Öhlin on 2018-10-09.
//  Copyright © 2018 Niil Öhlin. All rights reserved.
//

import Foundation
@testable import Tenta
import XCTest

class RoseTreeTests: XCTestCase {
    func testRose() {
        let rose = RoseTree(root: 0, forest: [
            RoseTree(root: 1, forest: [
                RoseTree(root: 3)
                ]),
            RoseTree(root: 2, forest: [
                RoseTree(root: 4)
                ])
            ])
        let array = Array(rose).map { $0.root() }
        XCTAssertEqual(array, [0, 1, 2, 3, 4])
    }

    func testMapRose() {
        let rose = RoseTree(root: 0, forest: [
            RoseTree(root: 1, forest: [
                RoseTree(root: 3)
            ]),
            RoseTree(root: 2, forest: [
                RoseTree(root: 4)
            ])
        ])

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

        let expanded = rose.expand { int in [int + 1, int - 1] }
        XCTAssertEqual(expanded.prefix(10).map { $0.root() }, [1, -2, 2, 2, 0, 4, -4, -1, -3, -4])
    }

    func testFlatMap() {
        let rose = RoseTree<Int>(seed: 1) { value in
            [value * -2, value * 2]
        }
        let flatMapped = rose.flatMap { (int: Int) -> RoseTree<String> in
            RoseTree<String>(root: "\(int)", forest: [
                RoseTree<String>(root: "\(int) is an int"),
                RoseTree<String>(root: "\(int) is fun")
            ])
        }
        XCTAssertEqual(flatMapped.prefix(5).map { $0.root() }, ["1", "1 is an int", "1 is fun", "-2", "2"])

    }

    func testSequence() {
        let forest = (0..<5).map { int in RoseTree(root: int) }
        let array = RoseTree<Int>.combine(forest: forest).root()
        XCTAssertEqual(array, [0, 1, 2, 3, 4])
    }

    func testBigSequence() {
        let firstTree = RoseTree<Int>(root: 0, forest: [
            RoseTree<Int>(root: 1),
            RoseTree<Int>(root: 2)
        ])
        let secondTree = RoseTree<Int>(root: 3, forest: [
            RoseTree<Int>(root: 4),
            RoseTree<Int>(root: 5)
        ])
        let forest = [firstTree, secondTree]
        let roseTree = RoseTree<Int>.combine(forest: forest)
        let expected = [[0, 3], [0, 4], [0, 5], [1, 3], [2, 3], [1, 4], [1, 5], [2, 4], [2, 5]]
        XCTAssertEqual(Array(roseTree).map { $0.root() }, expected)
    }

    func testDescription_terminates() {
        let rose = RoseTree<Int>(seed: 1) { value in
            [value * -2, value * 2]
        }
        _ = rose.description
    }

    func testCombine() {
        let rose = RoseTree(root: 0, forest: [
            RoseTree(root: 1),
            RoseTree(root: 2)
        ])
        let other = RoseTree(root: 3, forest: [
            RoseTree(root: 4),
            RoseTree(root: 5),
            RoseTree(root: 6, forest: [
                RoseTree(root: 7)
            ])
        ])

        let combined = rose.combine(with: other, transform: (+))
        XCTAssertEqual(Array(combined).map { $0.root() }, [3, 4, 5, 6, 4, 5, 7, 5, 6, 7, 6, 7, 8, 8, 9])
    }

    func testDotGraph() {
        let rose = RoseTree(root: 3, forest: [
            RoseTree(root: 4),
            RoseTree(root: 4),
            RoseTree(root: 6, forest: [
                RoseTree(root: 7)
                ]
            )]
        )
        print(rose.dotGraph)
    }
}
