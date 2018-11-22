//
// Created by Niil Öhlin on 2018-10-09.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public typealias Size = Double

/**
   Generator is a wrapper for a function that generates a value with accompanying shrink values in a `RoseTree`
*/
public struct Generator<ValueToTest> {
    private let maxFilterTries = 500
    public let generate: (Double, inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest>
    public init(generate: @escaping (Double, inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest>) {
        self.generate = generate
    }
}

public extension Generator {
    func map<Transformed>(_ transform: @escaping (ValueToTest) -> Transformed) -> Generator<Transformed> {
        return Generator<Transformed> { size, rng in
            self.generate(size, &rng).map(transform)
        }
    }

    func flatMap<Transformed>(
            _ transform: @escaping (ValueToTest) -> Generator<Transformed>
    ) -> Generator<Transformed> {
        return Generator<Transformed> { size, rng in
            let roseTree = self.generate(size, &rng)

            let newRng = rng

            return roseTree.flatMap { generatedValue in
                var newRng = newRng
                return transform(generatedValue).generate(size, &newRng)
            }
        }
    }

    /**
     Filters values from a generator.

     Usage:
     ```
     let even = Generator<Int>.int.filter { $0 % 2 == 0 }
     ```
     - Parameter predicate: The predicate for which the values must pass.
     - Returns: A new generator with values which holds for `predicate`
    */
    func filter(_ predicate: @escaping (ValueToTest) -> Bool) -> Generator<ValueToTest> {
        return Generator { size, rng in
            for retrySize in Int(size)..<(Int(size) + self.maxFilterTries) {
                let rose = self.generate(Double(retrySize), &rng)
                if let filteredRose = rose.filter(predicate) {
                    return filteredRose
                }
            }
            fatalError("Max filter retries. Try easing filter requirement or use a constructive approach")
        }
    }

    /// Create a generator that generate elements in `Sequence`
    static func element<SequenceType: Sequence>(from sequence: SequenceType) -> Generator<SequenceType.Element> {
        var array = [SequenceType.Element]()
        var iterator = sequence.makeIterator()
        return Generator<SequenceType.Element> { _, rng in
            if let nextElement = iterator.next() {
                array.append(nextElement)
            }
            guard let element = array.randomElement(using: &rng) else {
                fatalError("Could not generate an element from an empty sequence")
            }
            return RoseTree<SequenceType.Element>(root: { element }, forest: { () -> [RoseTree<SequenceType.Element>] in
                array.map { elementInGeneratedSequence in RoseTree(root: { elementInGeneratedSequence }) }
            })
        }
    }

    /// Create a generator which depend on the size.
    static func withSize<Type>(_ createGeneratorWithSize: @escaping (Size) -> Generator<Type>) -> Generator<Type> {
        return Generator<Type> { size, rng in
            createGeneratorWithSize(size).generate(size, &rng)
        }
    }
}

/**
 Placeholder function for running tests.
 */
public func runTest<TestValue>(
        gen: Generator<TestValue>, predicate: @escaping (TestValue) -> Bool) {
    var rng = SeededRandomNumberGenerator(seed: 100)

    for size in 0..<100 {
        let rose = gen.generate(Double(size), &rng)
        if !predicate(rose.root()) {
//            print("failed with tree: \(rose.description)")
            print("failed with value: \(rose.root())")
            //print("failed with rose: \(rose)")
            print("starting shrink")
            let failedValue = rose.shrink(predicate: predicate)
            print("failed with value: \(failedValue)")
            break
        }
    }
}

/**
 Run a test with the default generator.
 */
public func runTest<TestValue: Generatable>(_ predicate: @escaping (TestValue) -> Bool) {
    runTest(gen: TestValue.self.generator, predicate: predicate)
}
