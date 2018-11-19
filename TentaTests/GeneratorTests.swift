//
// Created by Niil Öhlin on 2018-10-09.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
@testable import Tenta
import XCTest

class GeneratorTests: XCTestCase {

    func testRunTest() {
        assert(generator: Generator<Int>.int, shrinksTo: 10, predicate: { (int: Int) in
            int < 10
        })
    }

    func testRunMoreComplicatedIntTest() {
        runTest(gen: Generator<Int>.int) { int in
            int < 21 || int % 2 == 1
        }
    }

    func testRunArray() {
        let intGenerator: Generator<Int> = Generator<Int>.int
        runTest(gen: Generator<Int>.array(elementGenerator: intGenerator)) { array in
            array.count < 20
        }
    }

    func testFilterGenerator() {
        let positiveEvenGenerator = Generator<Int>.int.filter { int in
            (int > 0 && int % 2 == 0)
        }
        runTest(gen: positiveEvenGenerator) { positiveEven in
            XCTAssert(positiveEven > 0)
            XCTAssert(positiveEven % 2 == 0)
            return positiveEven > 0 && positiveEven % 2 == 0
        }
    }

    func testRunTestWithDefaultGenerator() {
        runTest { (int: Int) in
            int > 0
        }
    }

    struct Point: Equatable {
        var x: Int
        var y: Int
    }

    func testCombine() {
        let pointGenerator = Int.generator.combine(with: Int.generator) { x, y in
            Point(x: x, y: y)
        }

        assert(generator: pointGenerator, shrinksTo: Point(x: 0, y: 20), predicate: { (point: Point) in
            point.y < 20
        })
    }

    func testInternallyShrinkingArray() {
        // This is why we do not shrink the elements in the array. The shrink tree _really_ explodes.
        let arrayOfGeneratorsGenerator = Int.generator.map {
            [Generator<Int>](repeating: Int.generator, count: abs($0))
        }

        let arrayGeneratorWithInternalIntShrinks = Generator<[Int]> { size, rng in
            let treeOfGenerators = arrayOfGeneratorsGenerator.generate(size, &rng)
            let treeOfInts = treeOfGenerators.flatMap { (generators: [Generator<Int>]) -> RoseTree<[Int]> in
                let forest: [RoseTree<Int>] = generators.map { (generator: Generator<Int>) in
                    generator.generate(size, &rng)
                }
                return RoseTree<[Int]>.combine(forest: forest)
            }
            return treeOfInts
        }
        runTest(gen: arrayGeneratorWithInternalIntShrinks) { (integers: [Int]) in
            integers.count < 3
        }
    }

    func testShrinkDouble() {
        assert(generator: Generator<Double>.double, shrinksTo: 5, isEqual: { abs($0 - $1) < 0.01 }, predicate: {
            $0 < 5
        })
    }

    func assert<T: Equatable>(
            generator: Generator<T>,
            shrinksTo minimumFailing: T,
            predicate: @escaping (T) -> Bool,
            file: StaticString = #file,
            line: UInt = #line) {
        assert(generator: generator, shrinksTo: minimumFailing, isEqual: (==), predicate: predicate)
    }

    func assert<T>(
            generator: Generator<T>,
            shrinksTo minimumFailing: T,
            isEqual: (T, T) -> Bool,
            predicate: @escaping (T) -> Bool,
            file: StaticString = #file,
            line: UInt = #line) {
        guard let value = generator.runAndReturnShrink(with: predicate) else {
            XCTFail("Generator did not fail", file: file, line: line)
            return
        }
        XCTAssert(
                isEqual(value, minimumFailing),
                "Generator did not shrink to \(minimumFailing)",
                file: file,
                line: line
        )
    }
}

extension Generator {
    func runAndReturnShrink(with predicate: @escaping (ValueToTest) -> Bool) -> ValueToTest? {
        var rng = SeededRandomNumberGenerator(seed: 100)

        for size in 0..<100 {
            let rose = generate(Double(size), &rng)
            if !predicate(rose.root()) {
                return rose.shrink(predicate: predicate)
            }
        }
        return nil
    }
}
