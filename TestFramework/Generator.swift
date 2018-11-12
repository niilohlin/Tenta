//
// Created by Niil Öhlin on 2018-10-09.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

struct Generator<T> {
    let generate: (Double, inout SeededRandomNumberGenerator) -> RoseTree<T>
}

extension Generator {
    static func int() -> Generator<Int> {
        let span = Span(origin: 0) { (-Int($0), Int($0)) }
        return Generator<Int> { size, rng in
            if size <= 0 {
                return RoseTree(root: { span.origin }, forest: { [] })
            }
            let range = span.span(size).0 ... span.span(size).1
            let value = Int.random(in: range, using: &rng)
            return RoseTree(root: { value }, forest: {
                0.shrinkTowards(destination: value)
            })

        }
    }

    static func array<TestValue>(
            elementGenerator: Generator<TestValue>) -> Generator<[TestValue]> {
        let span = Span(origin: 0) { (0, Int($0)) }
        return Generator<[TestValue]> { size, rng in
            if size <= 0 {
                return RoseTree(root: { [] }, forest: { [] })
            }
            let range = span.span(size).0 ... span.span(size).1
            var value = [RoseTree<TestValue>]()
            for _ in range {
                value.append(elementGenerator.generate(size, &rng))
            }
            return RoseTree<[Int]>.sequence(forest: value).flatMap { array in
                RoseTree(seed: array) { (parentArray: [TestValue]) in
                    parentArray.shrink()
                }
            }
        }
    }
}

func runTest<TestValue>(
        gen: Generator<TestValue>, predicate: @escaping (TestValue) -> Bool) {
    var rng = SeededRandomNumberGenerator(seed: 100)

    for size in 0..<100 {
        let rose = gen.generate(Double(size), &rng)
        if !predicate(rose.root()) {
            let failedValue = rose.shrink(predicate: predicate)
            print("failed with value: \(failedValue)")
            break
        }
    }
}
